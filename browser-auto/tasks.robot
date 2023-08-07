*** Settings ***
Documentation     Browser related examples.

# Library    AppiumLibrary
Library    RPA.Browser.Playwright    auto_closing_level=MANUAL    WITH NAME    Browser
# Library    RPA.Browser.Selenium    auto_close=${False}   WITH NAME    Selenium
Library    Collections
Library    ExtendedSelenium    auto_close=${False}    WITH NAME    Selenium
Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems
Library    RPA.Desktop
Library    String

Suite Setup    Set Headless
Task Teardown    Close Browsers


*** Variables ***
${HEADLESS}    ${True}


*** Keywords ***
Set Headless
    ${headless} =    Get Work Item Variable    headless    default=${True}
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
        ${ss} =    Screenshot
        Log To Console    ${ss}
    END


Test Timeout Message
    Browser.Open Browser    headless=${HEADLESS}
    Browser.Go To    https://google.com
    Set Browser Timeout    0.1s
    ${err} =    Catenate    SEPARATOR=
    ...    locator.click: Timeout 100ms exceeded.
    ...    *Use "Set Browser Timeout" for increasing the timeout or double check${SPACE}
    ...    your locator as the targeted element(s) couldn't be found.
    Run Keyword And Expect Error    *${err}*    Browser.Click    nothing

    TRY
        Browser.Click    nothing
    EXCEPT
        Log To Console    Excepted!
    END


Test Firefox
    # No simple `headless` switch with these. (require adding options or using
    #  `headlessfirefox` driver directly)
    # Selenium.Open Browser    https://www.google.com  # this fails
    Selenium.Open Firefox Site    https://www.google.com  # this runs

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
    Selenium.Open Available Browser    robocorp.com     browser_selection=Chrome
    ...    headless=${HEADLESS}    download=${True}
    ${out} =    Print To PDF
    Log To Console    Printed page on: ${out}


Test Webdrivers
    @{browsers} =    Create List    Chrome    Firefox    Edge    Safari,Ie
    FOR    ${browser}    IN    @{browsers}
        Open Specific Browser    ${browser}
        Close Browser
    END


Open In Incognito With Port And Custom Profile
    # ${options} =    Set Variable    add_argument("--incognito")
    ${options} =    Set Variable    add_argument("-inprivate")
    ${data_dir} =    Absolute Path    ${OUTPUT_DIR}${/}browser
    RPA.FileSystem.Create Directory    ${data_dir}    parents=${True}

    Open Available Browser    https://robocorp.com    browser_selection=Edge
    ...    headless=${HEADLESS}    port=${18888}    options=${options}
    ...    use_profile=${True}    profile_path=${data_dir}


Attach To Chrome
    Attach Chrome Browser    9222
    Selenium.Go To    https://robocorp.com


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
    ...    binary_location=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome
    IF    ${HEADLESS}
        Set To Dictionary    ${options}
        ...    arguments=--headless=new
    END

    ${url} =    Evaluate
    ...    RPA.core.webdriver.ChromeDriverManager(chrome_type="chromium").driver.get_driver_download_url()
    ...    modules=RPA.core.webdriver
    Log    Download URL: ${url}
    Log To Console    Download URL: ${url}
    @{vers} =    Evaluate
    ...    [RPA.core.webdriver.ChromeDriverManager(chrome_type="chromium").driver.get_browser_version_from_os(), RPA.core.webdriver.ChromeDriverManager(chrome_type="chromium").driver.get_latest_release_version()]
    ...    modules=RPA.core.webdriver
    Log    Versions: ${vers}
    Log To Console    Versions: ${vers}

    # ${version} =     Evaluate
    # ...    os.system("google-chrome --version || google-chrome-stable --version || google-chrome-beta --version || google-chrome-dev --version")
    # ...    os.system("chromium --version || chromium-browser --version")
    # ...    modules=os
    # Log    Version: ${version}
    # Log To Console     Version: ${version}

    # ${path} =    Evaluate    RPA.core.webdriver.download("Chrome")
    # ...    modules=RPA.core.webdriver
    # ${path} =    Set Variable    /Users/cmin/.robocorp/webdrivers/.wdm/drivers/chromedriver/mac_arm64/115.0.5790.102/chromedriver-mac-arm64/chromedriver
    # # ${path} =    Set Variable    /Users/cmin/.robocorp/webdrivers/.wdm/drivers/chromedriver/mac_arm64/114.0.5735.90/chromedriver
    # Open Browser    https://robocorp.com    browser=chrome
    # ...    options=${options}
    # # ...    executable_path=baddriver  # for Selenium Manager test
    # ...    executable_path=${path}  # our webdriver_manager from core
    # # ...    executable_path=bin${/}chromiumdriver  # manually downloaded webdriver

    # Open Available Browser    https://robocorp.com    browser_selection=Chrome
    # ...    headless=${HEADLESS}    options=${options}
    # ...    download=${True}


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


Download In Custom Location
    [Documentation]    Tests setting a custom downloading dir with various browsers.

    Set Download Directory    ${OUTPUT_DIR}
    # ${url} =    Set Variable    https://uwaterloo.ca/onbase/help/sample-pdf-documents
    ${url} =    Set Variable    https://robocorp.com/docs/security
    Open Available Browser    ${url}    browser_selection=firefox    headless=${HEADLESS}
    Click Link    Data protection whitepaper


Screenshot Robocorp Google search result
    Open Available Browser    about:blank    headless=${HEADLESS}
    ...    browser_selection=Chrome
    ${BROWSER_DATA} =    Set Variable    ${OUTPUT_DIR}${/}browser

    # NOTE(cmin764): As of 19.05.2023 this test passes in CI, Mac and Windows.
    Go To    www.google.com
    Wait Until Element Is Visible    q

    Input Text    q    Robocorp
    Click Element    q
    Selenium.Press Keys    q    ENTER
    Wait Until Element Is Visible    css:div.logo

    ${output_path} =    Screenshot    css:div.logo
    ...    filename=${BROWSER_DATA}${/}google-logo.png
    File Should Exist    ${output_path}

    ${output_path} =    Screenshot
    ...    filename=${BROWSER_DATA}${/}google-robocorp-result.png
    File Should Exist    ${output_path}
    Log To Console    Full page screenshot: ${output_path}


Demo Selenium
    Set Download Directory    ${OUTPUT_DIR}

    ${options} =    Set Variable    add_argument("-inprivate")
    ${data_dir} =    Absolute Path    ${OUTPUT_DIR}${/}browser
    RPA.FileSystem.Create Directory    ${data_dir}    parents=${True}

    Open Available Browser    https://robocorp.com/docs/security
    ...    browser_selection=Edge    headless=${HEADLESS}    options=${options}
    ...    use_profile=${True}    profile_path=${data_dir}

    Set Element Attribute    xpath://a[@href='#general']    style    color: red;
    # Click Link     Data protection whitepaper
    Click Element When Clickable    xpath://a[text()='Data protection whitepaper']

    [Teardown]    Close Browser


Get From Shadow Root
    Open Available Browser    http://watir.com/examples/shadow_dom.html
    ...    browser_selection=Chrome    headless=${HEADLESS}    download=${True}

    ${shadow_elem} =    Get WebElement    css:#shadow_host    shadow=${True}
    ${elem} =    Get WebElement    css:#shadow_content    parent=${shadow_elem}
    ${text} =    Selenium.Get Text    ${elem}
    Log To Console    ${text}

    ${nested_shadow_root} =    Get WebElement    css:#nested_shadow_host
    ...    parent=${shadow_elem}    shadow=${True}
    ${nested_elem} =    Get WebElement    css:#nested_shadow_content
    ...    parent=${nested_shadow_root}
    ${text} =    Selenium.Get Text    ${nested_elem}
    Log To Console    ${text}


Playwright Automatic Headless
    Set Browser Timeout    5000

    # Browser.Open Browser    https://robocorp.com
    Browser.New Browser    headless=${False}
    Browser.New Page    https://robocorp.com
