*** Settings ***
Documentation       Test connection related libraries. (SSH)

Library    SSHLibrary

Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections


*** Variables ***
${HOST}    34.140.103.130
${SSH_KEY_FILE}    /Users/cmin/.ssh/id_rsa
${COMMAND}    cd ~/Scripts && python3 printer.py


*** Keywords ***
Open Connection And Log In
    Open Connection     ${HOST}
    Login With Public Key    keyfile=${SSH_KEY_FILE}


*** Tasks ***
SSH Execute And Wait For Output
    ${out} =    Execute Command    ${COMMAND}
    Log To Console    Output: ${out}


SSH Write And Read From Terminal
    Write    ${COMMAND}
    WHILE  ${True}
        ${out} =    Read    delay=1s
        ${size} =    Get Length    ${out}
        IF    ${size} == ${0}    BREAK

        Log To Console    Output: ${out}
    END


SSH Execute And Read Async
    # Add as many commands as you like.
    @{commands} =    Create List
    ...    ${COMMAND} &  # not really necessary to have an `&` (background process)
    ...    whoami

    FOR    ${command}    IN    @{commands}
        Start Command    ${command}
    END

    ${count} =    Get Length    ${commands}
    FOR    ${idx}    IN RANGE    ${count}    0    -1
        ${out} =     Read Command Output
        Log To Console    Output #${idx}: ${out}
    END
