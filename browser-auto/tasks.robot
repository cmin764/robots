*** Settings ***
Documentation     Browser related examples.

# Library    AppiumLibrary
# Library    Browser    auto_closing_level=MANUAL
# Library    RPA.Browser.Selenium    auto_close=${False}   WITH NAME    Selenium
Library    ExtendedSelenium    auto_close=${False}    WITH NAME    Selenium
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems
Library    String

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


Open Specific Browser
    [Arguments]    ${browser}    ${options}=${None}
    Open Available Browser    https://robocorp.com    browser_selection=${browser}
    ...    headless=${HEADLESS}    download=${True}    options=${options}


*** Tasks ***
File Upload
    ${path} =    Absolute Path    devdata${/}file.txt
    ${data} =    Read File    ${path}
    Log    File ${path} to be uploaded with data: ${data}

    ${url} =    Set Variable    http://www.csm-testcenter.org/test?do=show&subdo=common&test=file_upload
    Browser.Open Browser    ${url}    headless=${HEADLESS}
    Sleep    1s
    Upload File By Selector    xpath=(//input[@name="file_upload"])[1]    ${path}
    Sleep    2s
    Click    xpath=//input[@value="Start HTTP upload"]
    Sleep    3s

    ${content} =    Browser.Get Text    (//table)[1]
    Log    Page table data: ${content}
    Should Contain    ${content}    file.txt


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
    ...    browser_selection=Firefox

    # Sleep    1s


Selenium Select Elements
    Selenium.Open Available Browser    https://my.hirezstudios.com/    headless=${HEADLESS}
    # ${locator} =    Set Variable    xpath://div[contains(@class, 'panel')]
    ${locator} =    Set Variable    class:hirez-acct-dashboard
    Selenium.Wait Until Element Is Visible    ${locator}
    ${elem} =    Selenium.Get WebElement    ${locator}
    Log To Console    ${elem}


Selenium Print Source
    Selenium.Open Available Browser    https://google.com    headless=${HEADLESS}   browser_selection=chrome
    ${source} =    Selenium.Get Source
    Log    ${source}


Test Appium Keyword
    ${timeout} =    Get Appium Timeout
    Log To Console    ${timeout}


Test Chrome Certs
    Open Chrome Site    https://www.robocorp.com    headless=${HEADLESS}


Print Page To PDF
    Selenium.Open Available Browser    robocorp.com    headless=${HEADLESS}    download=${True}
    ${out} =    Print To PDF
    Log To Console    Printed page on: ${out}
    # Print To PDF    ${OUTPUT_DIR}${/}robocorp.pdf


Test Webdrivers
    @{browsers} =    Create List    Chrome    Firefox    Edge    Safari,Ie
    FOR    ${browser}    IN    @{browsers}
        Open Specific Browser    ${browser}
        Close Browser
    END


Open In Incognito With Port And Custom Profile
    ${options} =    Set Variable    add_argument("--incognito")
    ${data_dir} =    Absolute Path    ${OUTPUT_DIR}${/}browser
    RPA.FileSystem.Create Directory    ${data_dir}    parents=${True}

    Open Available Browser    https://robocorp.com    browser_selection=Chrome
    ...    headless=${HEADLESS}    port=${18888}    options=${options}
    ...    use_profile=${True}    profile_path=${data_dir}


Attach To Chrome
    Attach Chrome Browser    9222
    Go To    https://robocorp.com


Open With Custom User Data
    # &{opts} =     Create Dictionary
    # ...    arguments=user-data-dir=/Users/cmin/Library/Application Support/Google/Chrome,--profile-directory=Profile 1
    # Open Available Browser    https://robocorp.com    headless=${HEADLESS}
    # ...    browser_selection=chrome    download=${False}
    # ...    options=${opts}

    Open Available Browser    https://robocorp.com  #  headless=${HEADLESS}
    ...    browser_selection=chrome  #   download=${False}
    ...    use_profile=${True}  #  profile_name=Profile 2


Open Chrome With Custom Webdriver
    &{options} =    Create Dictionary
    IF    ${HEADLESS}
        Set To Dictionary    ${options}
        ...    arguments    --headless
    END
    Open Browser    https://robocorp.com    browser=chrome
    ...    options=${options}
    ...    executable_path=/Users/cmin/.robocorp/webdrivers/.wdm/drivers/chromedriver/mac64/107.0.5304/chromedriver


Search Bus Route
    Open Available Browser    https://www.abhibus.com/

    Press Keys    source    New Delhi
    Press Keys    source    ENTER    TAB
    Press Keys    destination    Agra
    Press Keys    destination    ENTER    TAB    ENTER    TAB
    Click Link    //a[text()='Search']

    ${loc} =    Get Location
    ${new_loc} =    Replace String Using Regexp    ${loc}    \\d+-\\d+-\\d+    14-01-2023
    Go To    ${new_loc}


Open Edge In IE Mode
    ${url} =    Set Variable
    ...    http://www.csm-testcenter.org/test?do=show&subdo=common&test=file_upload
    ${webdriver} =    Set Variable    bin${/}IEDriverServer.exe

    &{ie_opts} =    Create Dictionary
    ...    initialBrowserUrl    https://www.google.com
    ...    ignoreProtectedModeSettings    ${True}
    ...    ignoreZoomSetting    ${True}
    ...    ie.browserCommandLineSwitches    --ie-mode-test
    &{ie_caps} =    Create Dictionary    se:ieOptions    ${ie_opts}
    &{ie_options} =    Create Dictionary    capabilities    ${ie_caps}

    Open Available Browser    ${url}    headless=${HEADLESS}    browser_selection=ie
    # Open Browser    ${url}    browser=ie    executable_path=${webdriver}
    # ...    options=${ie_options}

    Click Element When Visible    id:button
