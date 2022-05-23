import fnmatch
import os
import sys
from pathlib import Path

from RPA.Browser.Selenium import Selenium
from SeleniumLibrary.base import keyword
from selenium import webdriver
from webdrivermanager import ChromeDriverManager


class ExtendedSelenium(Selenium):

    USER_DATA = Path("output") / "Browser"
    USER_DATA_PATH = os.getenv("USER_DATA", str(USER_DATA)).strip()
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._chrome_ready = False
    
    def _setup_chrome(self):
        if self._chrome_ready:
            return
        
        cdm = ChromeDriverManager(link_path="AUTO")
        cdm.download_and_install()
        self._chrome_ready = True
                    
    @keyword
    def open_chrome_site(self, url, **kwargs):
        self._setup_chrome()
        
        options = webdriver.ChromeOptions()
        if self.USER_DATA_PATH:
            options.add_argument(f"user-data-dir={self.USER_DATA_PATH}")
        self.open_browser(
            url=url,
            options=options,
            **kwargs
        )
        
    @staticmethod
    def _set_firefox_binary(options):
        if "win32" in sys.platform:
            return
        
        # On *nix systems Firefox binary path still needs to be explicitly set.
        for path in os.getenv("PATH").strip().split(":"):
            if fnmatch.fnmatch(path, "*/holotree/*/bin"):
                # We just found the path containing firefox and geckodriver binaries.
                break
        else:
            raise Exception("Holotree path not found: please run with rcc/VSCode")
        
        options.binary_location = f"{path}/firefox"
    
    def _get_driver_args(self, browser, *args, **kwargs):
        # This is used with the `Open Available Browser` keyword.
        driver_args = super()._get_driver_args(browser, *args, **kwargs)
        if "firefox" in browser.lower():
            self._set_firefox_binary(driver_args[0]["options"])
        return driver_args
    
    @keyword
    def open_firefox_site(self, url, **kwargs):
        # These options might be replaced by the `executable_path` approach below.
        options = webdriver.FirefoxOptions()
        self._set_firefox_binary(options)
        
        self.open_browser(
            url=url,
            options=options,
            # Might be a good alternative to explore, although with this you can't
            #  attach to the browser service. (Firefox still gets open though)
            # executable_path=f"{path}/firefox",
            **kwargs
        )
