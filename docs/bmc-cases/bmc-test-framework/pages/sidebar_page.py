"""BMC 侧边栏导航页对象"""

import allure
import time
from playwright.sync_api import Page
from core.base_page import BasePage


class SidebarPage(BasePage):
    """BMC Web 侧边栏菜单导航。"""

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("悬浮到菜单: {menu_text}")
    def hover_menu(self, menu_text: str):
        selector = f"xpath=(//span[normalize-space(text())='{menu_text}'])[1]"
        self.hover(selector)

    @allure.step("点击子菜单: {submenu_text}")
    def click_submenu(self, submenu_text: str):
        selector = f"xpath=(//span[normalize-space(text())='{submenu_text}'])[1]"
        self.click(selector)
        time.sleep(2)

    @allure.step("导航到用户管理页面")
    def navigate_to_user_management(self):
        bmc_config = self.config.get("sidebar.bmc_config_menu")
        user_mgmt = self.config.get("sidebar.user_management_submenu")
        self.hover_menu(bmc_config)
        time.sleep(1)
        self.click_submenu(user_mgmt)

    @allure.step("导航到系统信息页面")
    def navigate_to_system_info(self):
        info = self.config.get("sidebar.info_menu")
        sys_info = self.config.get("sidebar.system_info_submenu")
        self.hover_menu(info)
        time.sleep(1)
        self.click_submenu(sys_info)

    @allure.step("导航到固件更新页面")
    def navigate_to_firmware_update(self):
        maintenance = self.config.get("sidebar.system_maintenance_menu")
        firmware = self.config.get("sidebar.firmware_update_submenu")
        self.hover_menu(maintenance)
        time.sleep(1)
        self.click_submenu(firmware)
