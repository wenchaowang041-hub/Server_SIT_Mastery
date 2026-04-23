"""BMC 帮助弹窗页对象"""

import allure
from playwright.sync_api import Page
from core.base_page import BasePage


class HelpDialogPage(BasePage):
    """BMC Web 帮助弹窗。"""

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("打开帮助弹窗")
    def open_help(self, timeout: int = 10000):
        icon = self.config.get("user_management.help_icon_selector")
        dialog = self.config.get("user_management.help_dialog_selector")
        self.click(icon)
        self.wait_for_selector(dialog, timeout=timeout)

    @allure.step("验证帮助文本: {expected}")
    def verify_help_text(self, selector: str, expected: str):
        actual = self.get_text(selector)
        assert actual == expected, f"帮助文本不匹配\n期望: {expected}\n实际: {actual}"
