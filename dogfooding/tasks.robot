*** Settings ***
Library           RPA.Browser.Selenium

*** Tasks ***
Start Browser
    My Browser Keyword
    Sleep    10s

Another task


*** Keywords ***
My Browser Keyword
    ${test}=    Open Available Browser    https://www.google.com    maximized=True
    Click Button
