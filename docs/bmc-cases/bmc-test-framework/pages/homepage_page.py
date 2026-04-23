"""BMC 首页页对象"""

import allure
import re
from playwright.sync_api import Page
from core.base_page import BasePage


class HomepagePage(BasePage):
    """BMC Web 首页。"""

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("导航到首页")
    def navigate_to_homepage(self):
        current = self.current_url
        base_url = current.rsplit('/', 1)[0] + '/'
        self.goto(base_url)
        self.page.wait_for_timeout(3000)
        try:
            self.click(self.config.get("homepage.home_link"))
            self.page.wait_for_timeout(3000)
        except Exception as e:
            print(f"导航到首页时出现异常: {e}")

    @allure.step("获取所有版本信息")
    def get_all_versions(self) -> dict:
        selectors = [
            "xpath=//div[contains(@class, 'version')]//span",
            "xpath=//td[contains(text(), '版本')]/following-sibling::td",
        ]
        versions = {}
        for selector in selectors:
            try:
                elements = self.page.locator(selector)
                for i in range(elements.count()):
                    text = elements.nth(i).inner_text().strip()
                    if text and re.search(r'\d+\.\d+\.\d+', text):
                        versions[text] = text
            except Exception:
                continue
        return versions if versions else {"default": "未知版本"}
