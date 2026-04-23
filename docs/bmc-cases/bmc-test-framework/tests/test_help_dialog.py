"""BMC 帮助弹窗文本验证测试"""

import allure


@allure.epic("BMC Web 自动化")
@allure.feature("帮助文本验证")
class TestHelpDialog:

    @allure.title("验证密码复杂度帮助信息")
    def test_password_complexity_help(self, login_page, sidebar_page, user_management_page, config):
        """登录 → 导航到用户管理 → 打开帮助弹窗 → 验证密码相关帮助文本。"""
        bmc_url = config.resolve_url()
        with allure.step("登录 BMC"):
            login_page.goto_login(bmc_url)
            login_page.login(
                username=config.get("credentials.username"),
                password=config.get("credentials.password"),
            )
            login_page.verify_login_success()

        with allure.step("导航到用户管理页面"):
            sidebar_page.navigate_to_user_management()
            user_management_page.verify_page_loaded()

        with allure.step("等待帮助文本加载"):
            user_management_page.wait_for_selector(user_management_page.PASSWORD_MIN_LENGTH, timeout=10000)

        expected = config.get("user_management.expected_texts") or {}
        checks = [
            ("密码最小长度帮助", user_management_page.get_password_length_text, expected.get("password_min_length", "")),
            ("启用复杂度帮助", user_management_page.get_complexity_enable_text, expected.get("complexity_enable", "")),
            ("密码有效期帮助", user_management_page.get_validity_period_text, expected.get("validity_period", "")),
            ("历史密码记录帮助", user_management_page.get_history_record_text, expected.get("history_record", "")),
            ("登录失败重试次数帮助", user_management_page.get_retry_count_text, expected.get("retry_count", "")),
            ("锁定时长帮助", user_management_page.get_lock_period_text, expected.get("lock_period", "")),
        ]

        for label, getter, exp_text in checks:
            with allure.step(f"验证: {label}"):
                actual = getter()
                assert actual == exp_text, f"{label} 不匹配\n期望: {exp_text}\n实际: {actual}"
