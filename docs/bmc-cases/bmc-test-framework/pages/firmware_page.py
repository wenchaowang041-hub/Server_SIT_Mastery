"""BMC 固件更新页对象"""

import allure
import os
from playwright.sync_api import Page
from core.base_page import BasePage


class FirmwarePage(BasePage):
    """BMC Web 固件更新页面。"""

    def __init__(self, page: Page, config):
        super().__init__(page)
        self.config = config

    @allure.step("进入更新模式")
    def enter_update_mode(self):
        try:
            self.click(self.config.get("firmware.update_mode_button"))
            self.page.wait_for_timeout(2000)
        except Exception as e:
            print(f"未找到进入更新模式按钮，可能已在更新模式: {e}")

    @allure.step("上传固件文件: {file_path}")
    def upload_firmware(self, file_path: str):
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"固件文件不存在: {file_path}")
        self.loc(self.config.get("firmware.file_input")).set_input_files(file_path)
        self.page.wait_for_timeout(2000)

    @allure.step("点击解析文件")
    def parse_firmware(self):
        self.click(self.config.get("firmware.parse_button"))
        self.page.wait_for_timeout(3000)

    @allure.step("点击上传镜像")
    def upload_firmware_image(self):
        self.click(self.config.get("firmware.upload_button"))
        self.page.wait_for_timeout(3000)
