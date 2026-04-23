"""根级 conftest：配置、驱动、页面 fixtures + Allure 失败截图"""

import pytest
import allure
from core.config_loader import ConfigLoader
from core.driver_factory import DriverFactory


def pytest_addoption(parser):
    parser.addoption("--bmc-model", action="store", default="default",
                     help="BMC 机型配置名称 (如: n810t_a2, default)")
    parser.addoption("--bmc-ip", action="store", default=None,
                     help="BMC IP 地址（覆盖配置默认值）")
    parser.addoption("--headless", action="store_true", default=False,
                     help="无头模式运行浏览器")


@pytest.fixture(scope="session")
def config(request):
    """加载合并后的配置。"""
    model = request.config.getoption("--bmc-model")
    ip = request.config.getoption("--bmc-ip")
    headless = request.config.getoption("--headless")
    overrides = {}
    if ip:
        overrides["bmc"] = {"default_ip": ip}
    if headless:
        overrides["playwright"] = {"headless": True}
    return ConfigLoader(model_name=model, runtime_overrides=overrides)


@pytest.fixture(scope="session")
def driver_factory(config):
    """创建 Playwright 驱动工厂（session 级别）。"""
    factory = DriverFactory(config.settings)
    yield factory
    factory.close()


@pytest.fixture()
def page(driver_factory):
    """每个测试获取一个新的 Page。"""
    p = driver_factory.create_page()
    yield p
    p.close()


@pytest.fixture()
def login_page(page, config):
    from pages.login_page import LoginPage
    return LoginPage(page, config)


@pytest.fixture()
def sidebar_page(page, config):
    from pages.sidebar_page import SidebarPage
    return SidebarPage(page, config)


@pytest.fixture()
def user_management_page(page, config):
    from pages.user_management_page import UserManagementPage
    return UserManagementPage(page, config)


@pytest.fixture()
def change_user_page(page, config):
    from pages.change_user_page import ChangeUserPage
    return ChangeUserPage(page, config)


@pytest.fixture()
def firmware_page(page, config):
    from pages.firmware_page import FirmwarePage
    return FirmwarePage(page, config)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """测试失败时自动截图并附加到 Allure 报告。"""
    outcome = yield
    rep = outcome.get_result()
    if rep.when == "call" and rep.failed:
        page = item.funcargs.get("page")
        if page:
            try:
                screenshot = page.screenshot(full_page=True)
                allure.attach(screenshot, name="failure-screenshot",
                              attachment_type=allure.attachment_type.PNG)
            except Exception:
                pass
