"""带 Allure 附件的断言辅助"""

import allure
from playwright.sync_api import Locator, expect


def verify_text(locator: Locator, expected: str, step_name: str = "验证文本"):
    """断言文本相等，失败时附加详细信息到 Allure。"""
    with allure.step(step_name):
        try:
            expect(locator).to_have_text(expected)
            allure.attach(f"验证通过: '{expected}'", name="断言结果", attachment_type=allure.attachment_type.TEXT)
        except AssertionError as e:
            actual = locator.inner_text()
            allure.attach(f"期望: '{expected}'\n实际: '{actual}'", name="断言失败", attachment_type=allure.attachment_type.TEXT)
            raise AssertionError(f"{step_name} 失败\n期望: {expected}\n实际: {actual}") from e


def verify_text_contains(locator: Locator, expected: str, step_name: str = "验证包含文本"):
    """断言文本包含预期字符串，失败时附加详细信息到 Allure。"""
    with allure.step(step_name):
        try:
            expect(locator).to_contain_text(expected)
            allure.attach(f"验证通过: 包含 '{expected}'", name="断言结果", attachment_type=allure.attachment_type.TEXT)
        except AssertionError as e:
            actual = locator.inner_text()
            allure.attach(f"期望包含: '{expected}'\n实际: '{actual}'", name="断言失败", attachment_type=allure.attachment_type.TEXT)
            raise AssertionError(f"{step_name} 失败\n期望包含: {expected}\n实际: {actual}") from e
