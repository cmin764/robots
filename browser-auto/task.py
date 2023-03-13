from RPA.Browser.Selenium import Selenium


browser_lib = Selenium()


def open_the_website(url):
    browser_lib.open_available_browser(url)


def search_for(term):
    input_field = "css:input"
    browser_lib.input_text(input_field, term)
    browser_lib.press_keys(input_field, "ENTER")


def store_screenshot(filename):
    browser_lib.screenshot(filename=filename)


def save_pdf_from_w3():
    print("Trying to save from w3schools")
    prefs = {
            'download.default_directory': "./output",
            'download.prompt_for_download': False,
            'download.directory_upgrade': True,
            'safebrowsing.enabled': False,
            'safebrowsing.disable_download_protection': True,
            'profile.default_content_setting_values.automatic_downloads': 1
        }
    browser_lib.open_available_browser(headless=True, preferences=prefs)

    url = "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_print"
    browser_lib.go_to(url)

    iframe = browser_lib.find_element('xpath://iframe[@id="iframeResult"]')
    browser_lib.driver.switch_to.frame(iframe)
    browser_lib.print_to_pdf("./output/w3.pdf")

    # btn_locator = 'xpath://button[contains(text(), "Print this page")]'
    # browser_lib.click_element_when_visible(btn_locator)
    # print("Button clicked.")


from RPA.Browser.Selenium import Selenium
from RPA.FileSystem import FileSystem

selenium = Selenium()
file_system = FileSystem()

OUTPUT_DIR = "output"

def download_pdf_in_custom_directory():
    selenium.set_download_directory(OUTPUT_DIR)
    file_name = "Robocorp-EULA-v1.0.pdf"
    selenium.open_available_browser(
        f"https://cdn.robocorp.com/legal/{file_name}", headless=False
    )
    import time
    time.sleep(10)
    files = file_system.list_files_in_directory(OUTPUT_DIR)
    for file_path in files:
        print(file_path)


# Define a main() function that calls the other functions in order:
def main():
    try:
        # open_the_website("https://robocorp.com/docs/")
        # search_for("python")
        # store_screenshot("output/screenshot.png")
        # save_pdf_from_w3()
        download_pdf_in_custom_directory()
    finally:
        browser_lib.close_all_browsers()


# Call the main() function, checking that we are running as a stand-alone script:
if __name__ == "__main__":
    main()
