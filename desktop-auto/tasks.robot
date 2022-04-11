*** Settings ***
Documentation     Investigating COMErrors with the Desktop/Windows libraries.

Library    Collections
Library    RPA.FileSystem
Library    RPA.Desktop    WITH NAME    Desktop
Library    RPA.Desktop.Windows    WITH NAME    Deskwin
Library    RPA.Windows    WITH NAME    Windows
Library    RPA.Excel.Application    WITH NAME    Excel
Library    RPA.Outlook.Application    WITH NAME    Outlook
Library    RPA.Word.Application    WITH NAME    Word


*** Keywords ***
Kill app by name
    [Arguments]     ${app_name}    ${icons}

    ${icons_dir} =    Set Variable    ${OUTPUT_DIR}${/}icons
    Create Directory    ${icons_dir}

    ${window_list} =   Windows.List Windows    icons=${icons}
    ...    icon_save_directory=${icons_dir}
    FOR  ${win}  IN   @{window_list}
        ${exists} =   Evaluate   re.match(r".*${app_name}.*", r"""${win}[title]""")

        IF  ${exists}
            Log    App details: ${win}
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
    ${run} =    Run Keyword And Ignore Error    Windows.Close Window    subname:Notepad control:WindowControl
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
    Kill app by name    Notepad    icons=${True}
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
    ${win} =    Windows.Control Window    subname:Kulcs-
    Log To Console    Controlling window: ${win}

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
    # # Windows.Print Tree   log_as_warnings=${True}
    ${vat_combo} =    Set Variable    control:EditControl id:lookUpEditVatObj
    # Windows.Click    ${vat_combo}
    # Windows.Send Keys    keys={HOME}{ENTER}  # goes on first option
    # ${last_value} =    Set Variable    ${EMPTY}
    # &{combos} =    Create Dictionary
    # Windows.Set Wait Time    0.1
    # FOR    ${idx}    IN RANGE    0    999
    #     ${value} =     Windows.Get Value    ${vat_combo}
    #     Exit For Loop If    "${value}" == "${last_value}"
    #     ${last_value} =    Set Variable    ${value}
    #     Set To Dictionary    ${combos}    ${value}    ${idx}
    #     Windows.Click    ${vat_combo}
    #     Windows.Send Keys    keys={DOWN}{ENTER}
    # END
    # Log Dictionary    ${combos}
    
    ${vat_value} =    Set Variable    18%-os áfa  # identify option by text value
    # ${downs_count} =    Get From Dictionary    ${combos}    ${vat_value}
    # Log To Console    Going down ${downs_count} times...
    # ${downs_str} =    Evaluate    '{DOWN}'*${downs_count}
    # Windows.Click    ${vat_combo}
    # Windows.Send Keys    keys={HOME}${downs_str}{ENTER}
    Windows.Set Value    ${vat_combo}    ${vat_value}
    Windows.Send Keys    keys={ENTER}

Open and close app with legacy Desktop library
    Desktop.Open File    devdata${/}workbook.xlsx
    ${app} =    Desktop.Open Application    Calc
    Deskwin.Open Application    Excel
    Sleep    1s
    Desktop.Close Application    ${app}
    Deskwin.Close All Applications

Send Keys Open File
    Windows.Windows Run   Notepad    wait_time=1
    Windows.Send Keys    keys={Ctrl}o
    Windows.Close Window    subname:Notepad

Send Keys LibreOffice
    Windows.Control Window    name:LibreOffice
    # Sets "Robocorp" as company in user data options.
    Windows.Send Keys    keys={LAlt}to    wait_time=1
    Windows.Send Keys    keys={LAlt}c
    Windows.Send Keys    keys=Robocorp    send_enter=${True}
