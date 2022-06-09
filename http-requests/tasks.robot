*** Settings ***
Documentation       Test and improve the HTTP/robotframework-requests library.

Library    RPA.FileSystem
Library    RPA.HTTP
Library    RPA.Robocorp.Vault
Library    RPA.Robocorp.WorkItems
Library    Zamzar


*** Variables ***
${test_txt}    devdata${/}test.txt
${portrait_gif}    devdata${/}portrait.gif


*** Keywords ***
Requests Gif To Png
    [Arguments]    ${api_key}
    ${resp_data} =    Convert File    ${portrait_gif}
    ...    target=png    api_key=${api_key}
    Log To Console    Requests GIF -> PNG: ${resp_data}
    RETURN    ${resp_data}


HTTP Gif To Png
    &{data} =    Create Dictionary    target_format    png
    ${portrait_file} =    Get File For Streaming Upload    ${portrait_gif}
    &{files} =    Create Dictionary    source_file    ${portrait_file}
    ${resp} =    POST On Session    zamzar    jobs    data=${data}    files=${files}
    ${resp_data} =    Set Variable    ${resp.json()}
    Log To Console    HTTP GIF -> PNG: ${resp_data}
    RETURN    ${resp_data}


*** Tasks ***
Zamzar Gif To Png
    ${secret} =    Get Secret    zamzar_jose
    @{creds} =    Create List  ${secret}[api_key_cosmin]    ${EMPTY}
    Create Session    zamzar    https://sandbox.zamzar.com/v1/
    ...    auth=${creds}

    # Send file to conversion job.
    ${with_rpa} =    Get Work Item Variable    rpa    default=${True}
    IF    ${with_rpa}
        ${resp_data} =    HTTP Gif To Png
    ELSE
        ${resp_data} =    Requests Gif To Png    ${secret}[api_key_cosmin]
    END
    Log To Console    Sleeping...
    Sleep    5s
    
    # Obtain status of the conversion job.
    ${job_id} =    Set Variable    ${resp_data}[id]
    ${resp} =    GET On Session    zamzar    jobs/${job_id}
    ${resp_data} =     Set Variable    ${resp.json()}
    Log To Console    Job status: ${resp_data}

    # Download the converted file.
    ${file_id} =    Set Variable    ${resp_data}[target_files][${0}][id]
    ${resp} =    GET On Session    zamzar    files/${file_id}/content    stream=${True}
    ${path} =    Set Variable    devdata${/}portrait.png
    Create Binary File    ${path}    ${resp.content}    overwrite=${True}
    Log To Console    Done: ${path}
