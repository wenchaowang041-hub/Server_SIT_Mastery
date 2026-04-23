"""Playwright 浏览器工厂：本地浏览器 or 远程 Playwright Server"""

from playwright.sync_api import sync_playwright, Browser, BrowserContext, Page


class DriverFactory:
    """创建 Playwright 浏览器/上下文/页面，支持本地和远程模式。"""

    def __init__(self, settings: dict):
        self._settings = settings
        self._playwright = None
        self._browser: Browser | None = None
        self._context: BrowserContext | None = None
        self._page: Page | None = None

    def create_page(self) -> Page:
        """启动浏览器并返回新页面。"""
        self._playwright = sync_playwright().start()
        pw_config = self._settings.get("playwright", {})
        remote_url = self._settings.get("remote", {}).get("url")

        if remote_url:
            self._browser = self._playwright.chromium.connect_over_cdp(remote_url)
        else:
            launch_options = {
                "headless": pw_config.get("headless", True),
                "slow_mo": pw_config.get("slow_mo", 0),
            }
            browser_name = pw_config.get("browser", "chromium")
            browser_type = getattr(self._playwright, browser_name)
            self._browser = browser_type.launch(**launch_options)

        viewport = pw_config.get("viewport", {"width": 1920, "height": 1080})
        timeout = pw_config.get("timeout", 30000)

        self._context = self._browser.new_context(
            viewport=viewport,
            ignore_https_errors=True,
        )
        self._context.set_default_timeout(timeout)

        self._page = self._context.new_page()
        return self._page

    def close(self):
        """清理所有资源。"""
        if self._page:
            self._page.close()
        if self._context:
            self._context.close()
        if self._browser:
            self._browser.close()
        if self._playwright:
            self._playwright.stop()
