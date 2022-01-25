*** Settings ***
Documentation     Investigating COMErrors with the new beta Windows library.

Library    RPA.Desktop    WITH NAME    Desktop
Library    RPA.Windows    WITH NAME    Windows


*** Keywords ***
Open App
    [Arguments]    ${app_name}
    
    ${window_list}=   Windows.List Windows
    FOR  ${win}  IN   @{window_list}
        ${exists} =   Evaluate   re.match(".*${app_name}.*", "${win}[title]")

        IF  ${exists}
            # Kill the process.
            ${command} =    Set Variable    os.kill($win["pid"], signal.SIGTERM)
            Evaluate    ${command}    signal
        END
    END
    Sleep    3s

    ${app} =     Desktop.Open Application    ${app_name}
    Sleep    3s

    # Controlling again a re-opened app will break with COMError.
    ${elem} =     Control Window   subname:${app_name}   timeout=3
    Log     Controlling element: ${elem}

    [Return]    ${elem}


*** Tasks ***
Open an application many times
    Open App    Notepad
    
    # Calling a 2nd time this will break on `Control Window`.
    # But commenting this line and running the robot twice in a row, will still work.
    Open App    Notepad
