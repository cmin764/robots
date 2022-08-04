*** Settings ***
Documentation     Browser related examples.

Library    AppiumLibrary
Library    Browser    auto_closing_level=MANUAL
# Library    RPA.Browser.Selenium   WITH NAME    Selenium
Library    ExtendedSelenium    auto_close=${False}    WITH NAME    Selenium
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
        Run Keyword And Ignore Error    Browser.Close Browser    ALL
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


Test Timeout Message
    Browser.Open Browser    headless=${HEADLESS}
    Browser.Go To    https://google.com
    Set Browser Timeout    0.1s
    ${err} =    Catenate    SEPARATOR=
    ...    locator.click: Timeout 100ms exceeded.
    ...    *Use "Set Browser Timeout" for increasing the timeout or double check${SPACE}
    ...    your locator as the targeted element(s) couldn't be found.
    Run Keyword And Expect Error    *${err}*    Click    nothing


Test Firefox
    # No simple `headless` switch with these. (require adding options or using
    #  `headlessfirefox` driver directly)
    # Selenium.Open Browser    https://www.google.com  # this fails
    # Selenium.Open Firefox Site    https://www.google.com  # this runs

    # Using our own RPA keywords.
    Selenium.Open Available Browser    https://www.google.com    headless=${HEADLESS}
    ...    browser_selection=firefox  # this also runs

    Sleep    1s


Selenium Select Elements
    Selenium.Open Available Browser    https://my.hirezstudios.com/    headless=${HEADLESS}
    # ${locator} =    Set Variable    xpath://div[contains(@class, 'panel')]
    ${locator} =    Set Variable    class:hirez-acct-dashboard
    Selenium.Wait Until Element Is Visible    ${locator}
    ${elem} =    Selenium.Get WebElement    ${locator}
    Log To Console    ${elem}


Selenium Print Source
    Selenium.Open Available Browser    https://google.com    headless=${HEADLESS}
    ${source} =    Selenium.Get Source
    Log    ${source}


Test Appium Keyword
    ${timeout} =    Get Appium Timeout
    Log To Console    ${timeout}


Test Chrome Certs
    Open Chrome Site    https://www.robocorp.com    headless=${HEADLESS}


Print Page To PDF
    Selenium.Open Available Browser    robocorp.com    headless=${HEADLESS}
    ${out} =    Print To PDF
    Log To Console    Printed page on: ${out}
    Print To PDF    ${OUTPUT_DIR}${/}robocorp.pdf
