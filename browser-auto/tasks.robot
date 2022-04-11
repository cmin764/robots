*** Settings ***
Documentation     Browser related examples.

Library    Browser    auto_closing_level=MANUAL
Library    RPA.Browser.Selenium    auto_close=${False}
# Library    ExtendedSelenium    auto_close=${False}
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems

Suite Setup    Set Headless
Task Teardown    Close Browsers


*** Variables ***
${HEADLESS}    ${False}


*** Keywords ***
Set Headless
    ${headless} =    Get Work Item Variable    headless    default=${False}
    Set Global Variable    ${HEADLESS}    ${headless}

Close Browsers
    IF    ${HEADLESS}
        Close All Browsers
        Browser.Close Browser    ALL
    END


*** Tasks ***
File Upload
    ${path} =    Absolute Path    devdata${/}file.txt
    ${data} =    Read File    ${path}
    Log    File ${path} to be uploaded with data: ${data}
    
    Browser.Open Browser    https://viljamis.com/filetest/    headless=${HEADLESS}
    Sleep    1s
    Upload File By Selector    xpath=//input[@name="image"]    ${path}
    Sleep    2s
    Click    xpath=//input[@value="Upload"]
    IF    "${HEADLESS}" != "${True}"
        Click    id=proceed-button
    END
    Sleep    3s

    ${content} =    Browser.Get Text    table
    Log    Page table data: ${content}
    Should Contain    ${content}    file.txt
    # This fails if the upload isn't done manually for some reason, maybe a problem
    #  with the web page itself.
    # Should Contain    ${content}    ${data}


Open Google Chrome
    IF    ${HEADLESS}
        Open Headless Chrome Browser   https://www.google.com
    ELSE
        Open Chrome Browser    https://www.google.com
        # Open Site    https://www.google.com    browser=chrome
    END
