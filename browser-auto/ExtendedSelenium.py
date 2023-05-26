import os
from pathlib import Path

from RPA.Browser.Selenium import Selenium
from selenium import webdriver
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
