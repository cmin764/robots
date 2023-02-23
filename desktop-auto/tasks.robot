*** Settings ***
Documentation     Investigating COMErrors with the Desktop/Windows libraries.

Library    Collections
Library    RPA.FileSystem
Library    RPA.Desktop    locators_path=locators.json    WITH NAME    Desktop
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
    ${elem} =    Windows.Get Element  # pulls the anchor
    Log To Console    Element after anchor set: ${elem}
    Should Be Equal    ${elem.name}    Calculator
    Deskwin.Screenshot    ${OUTPUT_DIR}${/}calculator.png    desktop=${True}
    Windows.Close Window    subname:Calc    timeout=1
    ${elem} =    Windows.Get Element  # pulls desktop since there's no more active anchor/window
    Should Be Equal    ${elem.name}    Desktop 1
    Log To Console    Element after window close: ${elem}

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

Match Quote Names
    ${loc} =    Windows.Control Window    subname:file'
    Log    With subname: ${loc}

    ${loc} =    Windows.Control Window    file.txt - Notepad    timeout=${1}
    Log    With name: ${loc}


Mac Detect Title With OCR Or Image
    # Opens a new TextEdit window to write text into.
    ${app} =    Desktop.Open Application    open    -a    TextEdit
    Sleep    1s
    Desktop.Press Keys    cmd    n

    # Double-click over "Untitled" title.
    # ${locator} =    Set Variable    ocr:Untitled  # OCR
    ${locator} =    Set Variable    alias:Untitled  # image locator
    ${match} =    Desktop.Wait For Element    ${locator}
    Log To Console    Coords: ${match.left} ${match.top} ${match.right} ${match.bottom}
    Click    ${match}    double click

    # Doesn't have effect since the editor was opened by another process that exited.
    Desktop.Close Application    ${app}


Windows Tick Checkbox
    Windows.Control Window    UIDemo
    ${checkbox} =    Windows.Get Element    GraphLabel
    ${toggle} =    Evaluate    $checkbox.item.GetTogglePattern()
    IF    ${toggle.ToggleState} == ${0}
        Evaluate    $toggle.Toggle()
    END


Adobe Click Menu Item
    Windows.Set Global Timeout    3

    Windows Run    Acrobat
    Control Window    subname:"Adobe Acrobat Reader DC"

    Windows.Click    type:MenuBar and name:"Application" > type:MenuItem and index:1
    # Windows.Click    File


Get Elements Coords
    Windows.Windows Run   Calc
    Windows.Control Window   subname:Calc
    @{buttons} =    Get Elements    id:NumberPad > class:Button
    Log To Console    ${buttons}


Path Explore Notepad
    [Setup]    Windows.Windows Run    Notepad

    # None of these work for Notepad. (but they appear in the recorder)
    # ${elem} =    Windows.Get Element    Text editor
    # ${elem} =    Windows.Get Element    subname:Notepad > name:"Text editor"

    ${main} =     Windows.Control Window   subname:Notepad   timeout=1
    Log    Controlled Notepad window: ${main}
    &{tree} =    Windows.Print Tree    ${main}    max_depth=${32}  # 7 is the max depth
    ...    return_structure=${True}
    Log Dictionary    ${tree}

    @{paths} =    Create List    2|1|2    3|1|4
    FOR    ${path}    IN    @{paths}
        ${elem} =    Windows.Get Element    path:${path}
        Log To Console    ${elem.name}
    END

    # Taken from the printed tree logs.
    Windows.Set Anchor    desktop
    ${elem} =    Get Element    subname:Notepad and type:WindowControl > path:2|1|2
    Log To Console    ${elem.name}  # should be Settings

    [Teardown]    Windows.Close Current Window
