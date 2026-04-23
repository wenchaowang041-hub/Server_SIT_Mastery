"""BMC 用户管理和更改用户帮助文本验证测试"""

import allure


@allure.epic("BMC Web 自动化")
@allure.feature("用户管理")
class TestUserManagement:

    @allure.title("验证用户管理帮助文本")
    def test_user_management_help(self, login_page, sidebar_page, user_management_page, config):
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

        with allure.step("验证用户管理帮助文本"):
            actual = user_management_page.get_user_manage_help_text()
            exp = expected.get("user_manage_help", "")
            assert actual == exp, f"用户管理帮助不匹配\n期望: {exp}\n实际: {actual}"

        with allure.step("验证用户组权限帮助文本"):
            actual = user_management_page.get_user_manage_root_help_text()
            exp = expected.get("user_manage_root_help", "")
            assert actual == exp, f"用户组权限帮助不匹配\n期望: {exp}\n实际: {actual}"


@allure.epic("BMC Web 自动化")
@allure.feature("更改用户")
class TestChangeUser:

    @allure.title("验证更改用户页面帮助文本")
    def test_change_user_help(self, login_page, sidebar_page, change_user_page, config):
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

        with allure.step("点击更改用户"):
            change_user_page.click_change_user()

        with allure.step("等待帮助文本加载"):
            change_user_page.wait_for_selector(change_user_page.USERNAME_RULE_1, timeout=10000)

        expected = config.get("change_user.expected_texts") or {}
        checks = [
            ("用户名规则1", change_user_page.get_username_rule_1_text),
            ("用户名规则2", change_user_page.get_username_rule_2_text),
            ("用户名规则3", change_user_page.get_username_rule_3_text),
            ("用户名规则4", change_user_page.get_username_rule_4_text),
            ("修改密码文本", change_user_page.get_change_password_text),
            ("管理员密码文本", change_user_page.get_admin_password_text),
            ("登入用户密码规则", change_user_page.get_password_rule_text),
            ("确认密码文本", change_user_page.get_confirm_password_text),
            ("网络访问文本", change_user_page.get_network_access_text),
            ("用户组名称文本", change_user_page.get_user_group_text),
            ("电子邮件格式文本", change_user_page.get_email_format_text),
            ("电子邮件ID文本", change_user_page.get_email_id_text),
            ("SSH密钥文本", change_user_page.get_ssh_key_text),
            ("SSH源文本", change_user_page.get_ssh_source_text),
            ("证书文本", change_user_page.get_certificate_text),
            ("上传证书文本", change_user_page.get_upload_certificate_text),
        ]

        for label, getter in checks:
            with allure.step(f"验证: {label}"):
                actual = getter()
                exp = expected.get(label, "")
                assert actual == exp, f"{label} 不匹配\n期望: {exp}\n实际: {actual}"
