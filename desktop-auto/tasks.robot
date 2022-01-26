*** Settings ***
Documentation     Investigating COMErrors with the Desktop/Windows libraries.

Library    RPA.Desktop    WITH NAME    Desktop
Library    RPA.Desktop.Windows    WITH NAME    Deskwin
Library    RPA.Windows    WITH NAME    Windows


*** Keywords ***
Open App
    [Arguments]    ${app_name}   ${sleep_time}
    
    ${window_list}=   Windows.List Windows
    FOR  ${win}  IN   @{window_list}
        ${exists} =   Evaluate   re.match(".*${app_name}.*", "${win}[title]")

        IF  ${exists}
            # Kill the process.
            ${command} =    Set Variable    os.kill($win["pid"], signal.SIGTERM)
            Log     Killing app: ${win}[title] (PID: $win["pid"])
            Evaluate    ${command}    signal
        END
    END
    Sleep    ${sleep_time}s

    ${app} =     Desktop.Open Application    ${app_name}
    Sleep    ${sleep_time}s

    # Controlling again a re-opened app will break with COMError.
    # And just by the fact we get control to a window (even once) it will break the
    #  rest of the Notepad related tasks. (not finding the window with subname)
    ${elem} =     Control Window   subname:${app_name}   timeout=${sleep_time}
    Log     Controlling element: ${elem}

    [Return]    ${elem}

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
    Open App    Calc    3  # here "active window = None"
    
    # Calling a 2nd time this will break on `Control Window` keyword.
    # Breaks on `rect = self.Element.CurrentBoundingRectangle` due to
    #  `"active window = %s" % window` logging.
    # But commenting this line and running the robot twice in a row, will still work.
    # Open App    Calc    3


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
    # Control Window   subname:Calc   timeout=1  # commenting this will make below stuff work

    # Errors with "ElementNotFound: Element not found with locator subname:Notepad".
    Desktop.Open Application    Notepad
    # Will try to find Notepad inside of the controlled window and it breaks because
    # Notepad is found starting from desktop level instead.
    Windows.Screenshot    subname:Notepad    ${OUTPUT_DIR}${/}success-control.png

    [Teardown]    Desktop.Close All Applications  # will fail to close Calculator
