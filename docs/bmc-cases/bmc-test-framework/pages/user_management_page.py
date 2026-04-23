"""BMC 用户管理页对象"""

import allure
from playwright.sync_api import Page
from core.base_page import BasePage


class UserManagementPage(BasePage):
    """BMC Web 用户管理页面。"""

    PASSWORD_MIN_LENGTH = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '密码最小长度帮助')]"
    COMPLEXITY_ENABLE = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '启用复杂度帮助')]"
    VALIDITY_PERIOD = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '密码有效期帮助')]"
    HISTORY_RECORD = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '历史密码记录帮助')]"
    RETRY_COUNT = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '登录失败重试次数帮助')]"
    LOCK_PERIOD = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '锁定时长帮助')]"
    MASS_HELP = "xpath=//div[contains(@class, 'alert-info') and contains(text(), '点击启用检查密码复杂度功能')]"
    USER_MANAGE_HELP = "xpath=//aside[2]//section[2]//div[contains(text(), '用户管理帮助')]"
    USER_MANAGE_ROOT_HELP = "xpath=//ul[li[contains(text(), '用户组') or contains(text(), '权限管理')]]"

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("验证用户管理页面已加载")
    def verify_page_loaded(self):
        self.wait_for_selector("xpath=//h1[contains(normalize-space(text()), '用户管理')]")

    def get_password_length_text(self) -> str:
        return self.get_text(self.PASSWORD_MIN_LENGTH)

    def get_complexity_enable_text(self) -> str:
        return self.get_text(self.COMPLEXITY_ENABLE)

    def get_validity_period_text(self) -> str:
        return self.get_text(self.VALIDITY_PERIOD)

    def get_history_record_text(self) -> str:
        return self.get_text(self.HISTORY_RECORD)

    def get_retry_count_text(self) -> str:
        return self.get_text(self.RETRY_COUNT)

    def get_lock_period_text(self) -> str:
        return self.get_text(self.LOCK_PERIOD)

    def get_mass_help_text(self) -> str:
        return self.get_text(self.MASS_HELP)

    def get_user_manage_help_text(self) -> str:
        return self.get_text(self.USER_MANAGE_HELP)

    def get_user_manage_root_help_text(self) -> str:
        return self.get_text(self.USER_MANAGE_ROOT_HELP)
