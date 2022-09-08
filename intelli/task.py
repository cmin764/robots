"""Template robot with Python."""


from RPA.Dialogs import Dialogs
from RPA.PDF import PDF


pdf_lib = PDF()
dialogs_lib = Dialogs()


def minimal_task():
    print(pdf_lib.open_pdf)
    dialogs_lib.run_dialog()


if __name__ == "__main__":
    minimal_task()
