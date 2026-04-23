"""BasePage：封装 Playwright 定位器和操作"""

from playwright.sync_api import Page, Locator, expect


class BasePage:
    """所有页面对象的基类，封装 Playwright 操作。"""

    def __init__(self, page: Page):
        self.page = page

    def loc(self, selector: str) -> Locator:
        return self.page.locator(selector)

    def click(self, selector: str, **kwargs):
        self.loc(selector).click(**kwargs)

    def fill(self, selector: str, value: str, **kwargs):
        self.loc(selector).fill(value, **kwargs)

    def hover(self, selector: str, **kwargs):
        self.loc(selector).hover(**kwargs)

    def get_text(self, selector: str) -> str:
        return self.loc(selector).inner_text()

    def get_attribute(self, selector: str, attr: str) -> str | None:
        return self.loc(selector).get_attribute(attr)

    def is_visible(self, selector: str, timeout: int = 5000) -> bool:
        try:
            expect(self.loc(selector)).to_be_visible(timeout=timeout)
            return True
        except Exception:
            return False

    def wait_for_selector(self, selector: str, timeout: int = 10000, state: str = "visible"):
        self.loc(selector).wait_for(state=state, timeout=timeout)

    def wait_for_url(self, pattern: str, timeout: int = 10000):
        self.page.wait_for_url(pattern, timeout=timeout)

    def expect_text(self, selector: str, expected: str):
        expect(self.loc(selector)).to_have_text(expected)

    def expect_visible(self, selector: str, timeout: int = 5000):
        expect(self.loc(selector)).to_be_visible(timeout=timeout)

    def expect_hidden(self, selector: str):
        expect(self.loc(selector)).to_be_hidden()

    def expect_url_contains(self, substring: str):
        expect(self.page).to_have_url(f".*{substring}.*")

    def goto(self, url: str):
        self.page.goto(url, wait_until="domcontentloaded")

    def reload(self):
        self.page.reload()

    @property
    def title(self) -> str:
        return self.page.title()

    @property
    def current_url(self) -> str:
        return self.page.url

    def take_screenshot(self, path: str):
        self.page.screenshot(path=path, full_page=True)

    def screenshot_png(self) -> bytes:
        return self.page.screenshot(full_page=True)
