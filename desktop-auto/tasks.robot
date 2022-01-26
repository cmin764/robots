*** Settings ***
Documentation     Investigating COMErrors with the Desktop/Windows libraries.

Library    RPA.Desktop    WITH NAME    Desktop
Library    RPA.Desktop.Windows    WITH NAME    Deskwin
Library    RPA.Windows    WITH NAME    Windows


*** Keywords ***
Open And Control App
    [Arguments]    ${app_name}   ${sleep_time}
    
    # Bad example of closing apps while in control of the affected window.

    # ${window_list}=   Windows.List Windows
    # FOR  ${win}  IN   @{window_list}
    #     ${exists} =   Evaluate   re.match(".*${app_name}.*", "${win}[title]")

    #     IF  ${exists}
    #         # # Kill the process directly.
    #         ${command} =    Set Variable    os.kill($win["pid"], signal.SIGTERM)
    #         Log     Killing app: ${win}[title] (PID: $win["pid"])
    #         Evaluate    ${command}    signal
    #     END
    # END
    # Sleep    ${sleep_time}s

    Desktop.Open Application    ${app_name}
    Sleep    ${sleep_time}s

    ${elem} =     Windows.Control Window   subname:${app_name}   timeout=${sleep_time}

    [Return]    {elem}

Screenshot Notepad
    Desktop.Open Application    Notepad
    Windows.Screenshot    subname:Notepad    ${OUTPUT_DIR}${/}success.png

Run Notepad Teardown
    # Shouldn't fail on Windows 11.
    Run Keyword If Test Failed    Windows.Screenshot    subname:Notepad    ${OUTPUT_DIR}${/}fail.png
    # But all opened apps should close.
    Desktop.Close All Applications

Screenshot Notepad Desktop
    Desktop.Open Application    Notepad
    Deskwin.Screenshot    ${OUTPUT_DIR}${/}success-desktop.png    desktop=${True}

Run Notepad Teardown Desktop
    Run Keyword If Test Failed     Deskwin.Screenshot    ${OUTPUT_DIR}${/}fail-desktop.png    desktop=${True}
    Desktop.Close All Applications


*** Tasks ***
Open an application many times  # This one fails with COMError.
    ${elem} =     Open And Control App    Calc    2
    Log     Controlling element: ${elem}
    Windows.Close Current Window
    
    ${elem} =     Open And Control App    Calc    2
    Log     Controlling new element but forgetting to close window: ${elem}
    # Windows.Close Current Window

    [Teardown]    Desktop.Close All Applications  # this doesn't work on Calculator


Notepad Screenshots  # This one runs ok on Windows 11.
    # Take multiple screenshots within the same output image.
    Screenshot Notepad
    Screenshot Notepad
    [Teardown]   Run Notepad Teardown


Notepad Screenshot Desktop  # Works well on Windows 11.
    # Even with single/multiple screenshots.
    Screenshot Notepad Desktop
    # Screenshot Notepad Desktop
    [Teardown]   Run Notepad Teardown Desktop


Screenshot Notepad while controlling Calc
    Desktop.Open Application    Calc
    Sleep     2s  # without a little sleep, the controller can't find Calculator
    Control Window   subname:Calc   timeout=1  # commenting this will make below stuff work

    # Errors with "ElementNotFound: Element not found with locator subname:Notepad".
    Desktop.Open Application    Notepad
    # Will try to find Notepad inside of the controlled window and it breaks because
    # Notepad is found starting from desktop level instead.
    Windows.Screenshot    subname:Notepad    ${OUTPUT_DIR}${/}success-control.png

    [Teardown]    Desktop.Close All Applications  # will fail to close Calculator
