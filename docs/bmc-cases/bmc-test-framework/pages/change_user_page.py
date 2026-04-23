"""BMC 更改用户页对象"""

import allure
from playwright.sync_api import Page
from core.base_page import BasePage


class ChangeUserPage(BasePage):
    """BMC Web 更改用户设置页面。"""

    USERNAME_RULE_1 = "xpath=//li[contains(text(), '用户名是一个长度为 1 到 16 个数字及字母组成的字符串')]"
    USERNAME_RULE_2 = "xpath=//li[contains(text(), '必须要以字母作为起始的字符')]"
    USERNAME_RULE_3 = "xpath=//li[contains(text(), '区分大小写')]"
    USERNAME_RULE_4 = "xpath=//li[contains(text(), '允许特殊字符')]"
    CHANGE_PASSWORD = "xpath=//form/div[2]/div[1][contains(text(), '密码')]"
    ADMIN_PASSWORD = "xpath=//form/div[3]//*[contains(text(), '请输入当前管理员的密码')]"
    PASSWORD_RULE = "xpath=//form/div[4][contains(text(), '若启用密码复杂度检查')]"
    CONFIRM_PASSWORD = "xpath=//form/div[6][contains(text(), '再一次确认密码')]"
    NETWORK_ACCESS = "xpath=//form/div[8][contains(text(), '选中复选框以启用用户的网络访问')]"
    USER_GROUP = "xpath=//form/div[12][contains(text(), '用户组名称帮助')]"
    EMAIL_FORMAT = "xpath=//form/div[28][contains(text(), '指定电子邮件格式')]"
    EMAIL_ID = "xpath=//form/div[30][contains(text(), '输入用户的电子邮件 ID')]"
    SSH_KEY = "xpath=//form/div[32][contains(text(), '显示有效')]"
    SSH_SOURCE = "xpath=//form/div[34][contains(., '使用搜寻按钮')]"
    CERTIFICATE = "xpath=//form/div[36][contains(text(), '本栏位显示已有的用户证书')]"
    UPLOAD_CERTIFICATE = "xpath=//form/div[38][contains(text(), '点击搜寻按钮选择要上传的用户证书')]"

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("点击'更改用户'链接")
    def click_change_user(self):
        selector = self.config.get("change_user.change_user_link")
        self.click(selector)
        self.page.wait_for_timeout(1000)

    def get_username_rule_1_text(self) -> str:
        return self.get_text(self.USERNAME_RULE_1)

    def get_username_rule_2_text(self) -> str:
        return self.get_text(self.USERNAME_RULE_2)

    def get_username_rule_3_text(self) -> str:
        return self.get_text(self.USERNAME_RULE_3)

    def get_username_rule_4_text(self) -> str:
        return self.get_text(self.USERNAME_RULE_4)

    def get_change_password_text(self) -> str:
        return self.get_text(self.CHANGE_PASSWORD)

    def get_admin_password_text(self) -> str:
        return self.get_text(self.ADMIN_PASSWORD)

    def get_password_rule_text(self) -> str:
        return self.get_text(self.PASSWORD_RULE)

    def get_confirm_password_text(self) -> str:
        return self.get_text(self.CONFIRM_PASSWORD)

    def get_network_access_text(self) -> str:
        return self.get_text(self.NETWORK_ACCESS)

    def get_user_group_text(self) -> str:
        return self.get_text(self.USER_GROUP)

    def get_email_format_text(self) -> str:
        return self.get_text(self.EMAIL_FORMAT)

    def get_email_id_text(self) -> str:
        return self.get_text(self.EMAIL_ID)

    def get_ssh_key_text(self) -> str:
        return self.get_text(self.SSH_KEY)

    def get_ssh_source_text(self) -> str:
        return self.get_text(self.SSH_SOURCE)

    def get_certificate_text(self) -> str:
        return self.get_text(self.CERTIFICATE)

    def get_upload_certificate_text(self) -> str:
        return self.get_text(self.UPLOAD_CERTIFICATE)
