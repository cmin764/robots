*** Settings ***
Documentation       Java app automation playground.

Library    Collections
Library    Process
Library    RPA.JavaAccessBridge    ignore_callbacks=${True}

Suite Setup    Run Java App
Task Setup    Reset Window


*** Variables ***
${TEST_APP}    ${CURDIR}${/}bin${/}test-app
${TITLE}    Chat Frame


*** Keywords ***
Run Java App
    Run Process     makejar.bat     shell=${True}    cwd=${TEST_APP}
    Start Process   java    -jar    BasicSwing.jar    ${TITLE}      cwd=${TEST_APP}

Reset Window
    Select Window By Title    ${TITLE}
    Click Element    role:push button and name:Clear


*** Tasks ***
Update and refresh table
    [Documentation]    Read a table with a simple library keyword.

    # Just read the table's visible children.
    @{rows} =    Read Table    role:table
    ${count} =    Get Length    ${rows}
    Log To Console    Visible rows: ${count}
    Log List    ${rows}

    # Update the table with multiple appended elements.
    Click Element    role:push button and name:Update

    # Read the table again, this time including all the available children.
    @{rows} =    Read Table    role:table    visible_only=${False}
    ${count} =    Get Length    ${rows}
    Log To Console    All rows: ${count}
    Log List    ${rows}
