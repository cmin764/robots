"""Template robot with Python."""


from RPA.Dialogs import Dialogs
from RPA.PDF import PDF
from SeleniumLibrary import SeleniumLibrary


pdf_lib = PDF()
dialogs_lib = Dialogs()
selenium_lib = SeleniumLibrary()


def minimal_task():
    print(pdf_lib.open_pdf)
    print(selenium_lib.open_browser)
    dialogs_lib.run_dialog()


if __name__ == "__main__":
    minimal_task()
