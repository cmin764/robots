*** Settings ***
Documentation     Browser related examples.

# Library    RPA.Browser.Playwright
Library    RPA.Browser.Selenium  auto_close=${FALSE}
# Library    RPA.FileSystem


*** Variables ***
# ${HEADLESS}    ${True}
${URL}  https://www.google.com


*** Tasks ***
# File Upload
#     ${path} =    Absolute Path    devdata${/}file.txt
#     ${data} =    Read File    ${path}
#     Log    File ${path} to be uploaded with data: ${data}
    
#     Open Browser    https://viljamis.com/filetest/    headless=${HEADLESS}
#     Sleep    1s
#     Upload File By Selector    xpath=//input[@name="image"]    ${path}
#     Sleep    2s
#     Click    xpath=//input[@value="Upload"]
#     IF    "${HEADLESS}" != "${True}"
#         Click    id=proceed-button
#     END
#     Sleep    3s

#     ${content} =    Get Text    table
#     Log    Page table data: ${content}
#     Should Contain    ${content}    file.txt
#     # This fails if the upload isn't done manually for some reason, maybe a problem
#     #  with the web page itself.
#     # Should Contain    ${content}    ${data}

*** Tasks ***
Minimal task
    Open Available Browser  url=${URL}
