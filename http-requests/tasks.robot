*** Settings ***
Documentation       Test and improve the HTTP/robotframework-requests library.

Library    RPA.HTTP
Library    RPA.Robocorp.Vault
Library    Zamzar


*** Variables ***
${test_txt}    devdata${/}test.txt


*** Tasks ***
Zamzar File Stream
    ${secret} =    Get Secret    zamzar_jose
    @{creds} =    Create List  ${secret}[api_key]  ${EMPTY}
    Create Session    zamzar    https://sandbox.zamzar.com/v1/    auth=${creds}

    &{data} =    Create Dictionary  target_format=txt
    ${file} =    Get File For Streaming Upload    ${test_txt}
    &{files} =    Create Dictionary    source_file=${file}

    ${resp} =    Post On Session    zamzar    jobs    files=${files}    data=${data}
    Log To Console    ${resp}


Python Zamzar Stream
    ${secret} =    Get Secret    zamzar_jose
    ${resp} =    Post Text    ${test_txt}    ${secret}[api_key]
    Log To Console    ${resp}
