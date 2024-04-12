from robocorp import windows
from robocorp.tasks import task, teardown
from robocorp.windows import Desktop

from RPA.Robocorp.utils import get_output_dir
from RPA.Windows import Windows


desktop = Desktop()
rpa_windows = Windows()

NOTEPAD_LOCATOR = 'control:WindowControl and class:Notepad'
PAGE_SETUP_LOCATOR = '"Page setup"'


@task
def notepad_automation():
    desktop.windows_run("notepad.exe")
    notepad_window = windows.find_window(NOTEPAD_LOCATOR)
    notepad_window.click("control:MenuItemControl and name:File")

    # On the old notepad the menu is: 'Page Setup...'
    # On the new notepad the menu is: 'Page setup'
    page = notepad_window.find("control:MenuItemControl and subname:Page")
    # This also works:
    # page = appWindow.find('control:MenuItemControl and subname:"ge set" class:MenuFlyoutItem')
    page.click()  # this one just highlights
    page.click()  # the 2nd click finally clicks the menu item

    # rpa_windows.control_window(PAGE_SETUP_LOCATOR)  # this works the legacy way
    page_window = notepad_window.find(PAGE_SETUP_LOCATOR)
    page_window.send_keys("{Enter}")  # "clicks" OK button
    # notepad_window.click("class:Button name:OK")  # also works in the absence of the finding above

    # The following line fails with robocorp-windows v0.0.1 and produces a LOT of logging.
    # desktop.find('control:MenuItemControl and name:Nothing')
    # This one isn't that bad, but still fails with the unicode error when printing the exception.
    try:
        notepad_window.find('control:MenuItemControl and name:Nothing', timeout=1)
    except Exception as exc:
        # pass
        print(exc)

    # Screenshot of the application window confirms the result
    notepad_window.screenshot(get_output_dir() / "notepad-ss.png")


@teardown
def notepad_cleanup(task):
    notepad_window = windows.find_window(NOTEPAD_LOCATOR)
    notepad_window.close_window()
