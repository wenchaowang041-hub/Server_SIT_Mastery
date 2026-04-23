"""BMC 登录测试"""

import allure


@allure.epic("BMC Web 自动化")
@allure.feature("登录认证")
class TestLogin:

    @allure.title("验证登录功能")
    def test_login_success(self, login_page, config):
        """使用默认凭据登录 BMC，验证导航栏加载成功。"""
        bmc_url = config.resolve_url()
        with allure.step("打开 BMC 登录页面"):
            login_page.goto_login(bmc_url)
        with allure.step("执行登录"):
            login_page.login(
                username=config.get("credentials.username"),
                password=config.get("credentials.password"),
            )
        with allure.step("验证登录成功"):
            login_page.verify_login_success()
