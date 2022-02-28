*** Settings ***
Documentation     Investigating COMErrors with the Desktop/Windows libraries.

Library    RPA.Desktop    WITH NAME    Desktop
Library    RPA.Desktop.Windows    WITH NAME    Deskwin
Library    RPA.Windows    WITH NAME    Windows
Library    RPA.Excel.Application    WITH NAME    Excel
Library    RPA.Outlook.Application    WITH NAME    Outlook
Library    RPA.Word.Application    WITH NAME    Word
Library    Collections


*** Keywords ***
Kill app by name
    [Arguments]     ${app_name}

    ${window_list} =   Windows.List Windows
    FOR  ${win}  IN   @{window_list}
        ${exists} =   Evaluate   re.match(".*${app_name}.*", """${win}[title]""")

        IF  ${exists}
            ${command} =    Set Variable    os.kill($win["pid"], signal.SIGTERM)
            Log     Killing app: ${win}[title] (PID: $win["pid"])
            Evaluate    ${command}    signal
        END
    END

Open And Control App
    [Arguments]    ${app_name}   ${sleep_time}
    
    # Bad example of closing apps while in control of the affected window.

    # Kill app by name    ${app_name}
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

Keep open a single Notepad
    Windows.Set Global Timeout    6
    ${closed} =     Set Variable    0
    ${run} =    Run Keyword And Ignore Error    Windows.Close Window    subname:Notepad control:WindowControl  # in development keyword
    IF    "${run}[0]" == "PASS"
        ${closed} =    Set Variable    ${run}[1]
    END
    Log    Closed Notepads: ${closed}
    Windows.Windows Run   Notepad


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

    Desktop.Open Application    Notepad
    # Errors with "ElementNotFound: Element not found with locator subname:Notepad".
    # Will try to find Notepad inside of the controlled window and it breaks because
    # Notepad is found starting from desktop level instead.
    Windows.Screenshot    subname:Notepad    ${OUTPUT_DIR}${/}success-control.png

    [Teardown]    Desktop.Close All Applications  # will fail to close Calculator

Get elements of controlled window
    [Setup]  Windows.Windows Run   Notepad
    
    # ${app} =   Desktop.Open Application    Notepad
    # Sleep    1s
    
    ${window} =     Windows.Control Window   subname:Notepad   timeout=1
    Log    Controlled Notepad window: ${window}

    ${attributes} =  Windows.List Attributes  ${window}
    Log    Attributes: ${attributes}
    ${elements} =  Windows.Get Elements  ${window}
    Log    Elements: ${elements}

    # [Teardown]    Desktop.Close Application    ${app}
    [Teardown]    Windows.Close Current Window

Control window after closing linked root element
    [Setup]    Keep open a single Notepad
    ${window} =     Windows.Control Window   subname:Notepad control:WindowControl
    Log    Controlling Notepad window: ${window}

    Kill app by name    Notepad

    Windows.Windows Run   Calc
    # Tests against `COMError` fixes.
    ${window} =     Windows.Control Window   subname:Calc    main=${False}
    Log    Controlling Calculator window: ${window}

    [Teardown]    Windows.Close Current Window  # closes Calculator (last active window)

Tree printing and controlled anchor cleanup
    Windows.Print Tree     #capture_image_folder=output${/}controls
    Windows.Windows Run   Calc
    ${win} =    Windows.Control Window   subname:Calc control:WindowControl    timeout=1
    Windows.Set Anchor    ${win}
    Windows.Close Window    subname:Calc control:WindowControl    timeout=1

Test desktop windows and apps
    [Setup]    Keep open a single Notepad

    ${ver} =    Windows.Get Os Version
    Log    Running on Windows ${ver}
    
    # Windows related calls.
    ${window} =     Windows.Control Window   subname:Notepad
    Log    Controlling Notepad window: ${window}
    Kill app by name    Notepad
    Windows.Windows Run   Calc
    # Tests against `COMError` fixes.
    ${window} =     Windows.Control Window   subname:Calc    main=${False}
    Log    Controlling Calculator window: ${window}
    Windows.Close Current Window

    # Excel, Word and Outlook apps. (needs these apps installed on host)
    Excel.Open Application    visible=${True}
    Excel.Open Workbook           devdata${/}workbook.xlsx
    Excel.Export as PDF           ${OUTPUT_DIR}${/}workbook.pdf
    Excel.Quit Application

    # Desktop, Windows and Desktop.Windows.
    Windows.Print Tree     #capture_image_folder=output${/}controls
    Desktop.Open Application    Calc
    ${win} =    Windows.Control Window   subname:Calc    timeout=5
    Windows.Set Anchor    ${win}
    Deskwin.Screenshot    ${OUTPUT_DIR}${/}calculator.png    desktop=${True}
        
    [Teardown]    Windows.Close Window    subname:Calc    timeout=1


Control Kulcs App
    # Record mouse clicks and identify app windows with "windows-record" script.

    # Logs all elements found in the app as warnings into a tree view.
    Windows.Control Window    subname:Kulcs
    # Windows.Print Tree    log_as_warnings=${True}
    # ...    capture_image_folder=${OUTPUT_DIR}${/}kulcs-controls

    # Clicks a "+" sign over "Termekek", then exits.
    # Windows.Click   name:'Termékek'    wait_time=1
    # Windows.Click   name:'Új termék'    wait_time=3
    # Windows.Send Keys    keys={ESC}{TAB}{ENTER}    interval=0.5

    # Collects and changes VAT value.
    Windows.Click   name:'Termékek'    wait_time=1
    Windows.Click   name:'Új termék'    wait_time=2
    Windows.Control Window    Termék
    # Windows.Print Tree   log_as_warnings=${True}
    ${vat_combo} =    Set Variable    control:EditControl id:lookUpEditVatObj
    Windows.Click    ${vat_combo}
    Windows.Send Keys    keys={HOME}{ENTER}
    ${last_value} =    Set Variable    ${EMPTY}
    &{combos} =    Create Dictionary
    Windows.Set Wait Time    0.1
    FOR    ${idx}    IN RANGE    0    999
        Log To Console    value start
        ${value} =     Windows.Get Value    ${vat_combo}
        Log To Console    value finish
        Exit For Loop If    "${value}" == "${last_value}"
        ${last_value} =    Set Variable    ${value}
        Set To Dictionary    ${combos}    ${value}    ${idx}
        Log To Console    click start
        Windows.Click    ${vat_combo}
        Windows.Send Keys    keys={DOWN}{ENTER}
        Log To Console    click finish
    END
    Log Dictionary    ${combos}
