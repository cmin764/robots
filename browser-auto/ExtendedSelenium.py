import os
from pathlib import Path

from RPA.Browser.Selenium import Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from SeleniumLibrary.base import keyword


class ExtendedSelenium(Selenium):

    USER_DATA = Path("output") / "Browser"
    USER_DATA_PATH = os.getenv("USER_DATA", str(USER_DATA)).strip()

    @keyword
    def open_chrome_site(self, url, headless=False, **kwargs):
        options = webdriver.ChromeOptions()
        if self.USER_DATA_PATH:
            options.add_argument(f"user-data-dir={self.USER_DATA_PATH}")
        if headless:
            options.add_argument("--headless=new")
        options.set_capability("acceptInsecureCerts", True)
        self.open_browser(
            url=url,
            options=options,
            browser="chrome",
            **kwargs
        )

    @keyword
    def open_firefox_site(self, url, **kwargs):
        # These options might be replaced by the `executable_path` approach below.
        options = webdriver.FirefoxOptions()
        self.open_browser(
            url=url,
            options=options,
            browser="firefox",
            **kwargs
        )

    @keyword
    def get_shadow_webelement(self, locator, shadow=False, parent=None):
        if parent:
            # web_elem = self.find_element(locator, parent=parent)
            web_elem = parent.find_element(By.CSS_SELECTOR, locator)
        else:
            web_elem = self.get_webelement(locator)
        if shadow:
            web_elem = web_elem.shadow_root
        return web_elem
