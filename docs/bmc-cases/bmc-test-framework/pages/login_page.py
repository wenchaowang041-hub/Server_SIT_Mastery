"""BMC 登录页对象"""

import allure
from playwright.sync_api import Page
from core.base_page import BasePage


class LoginPage(BasePage):
    """BMC Web 登录页面。"""

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @property
    def _username_selector(self):
        return self.config.get("login.username_selector")

    @property
    def _password_selector(self):
        return self.config.get("login.password_selector")

    @property
    def _submit_selector(self):
        return self.config.get("login.submit_button_selector")

    @property
    def _success_indicator(self):
        return self.config.get("login.login_success_indicator")

    @allure.step("打开 BMC 登录页面: {url}")
    def goto_login(self, url: str):
        self.goto(url)

    @allure.step("输入用户名: {username}")
    def enter_username(self, username: str):
        self.fill(self._username_selector, username)

    @allure.step("输入密码")
    def enter_password(self, password: str):
        self.fill(self._password_selector, password)

    @allure.step("点击登录按钮")
    def submit(self):
        self.click(self._submit_selector)

    @allure.step("完整登录流程")
    def login(self, username: str, password: str):
        self.enter_username(username)
        self.enter_password(password)
        self.submit()

    @allure.step("验证登录成功")
    def verify_login_success(self, timeout: int = 20000):
        self.wait_for_selector(self._success_indicator, timeout=timeout)
