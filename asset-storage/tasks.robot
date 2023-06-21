*** Settings ***
Documentation       Asset Storage example

Library    Collections
Library    OperatingSystem
Library    RPA.Robocorp.Storage

Suite Setup    Set Workspace


*** Variables ***
${WORKSPACE}    d043e967-5c2b-4a2d-8919-789f82859ba2


*** Keywords ***
Set Workspace
    ${debug} =    Get Environment Variable    DEBUG    ${EMPTY}
    IF    "${debug}"
        Set Environment Variable    RC_WORKSPACE_ID    ${WORKSPACE}
    END


*** Tasks ***
List All Assets
    @{assets} =    List Assets
    Log List    ${assets}

Store And Read Asset
    [Setup]    Set Asset    cosmin    cosmin@robocorp.com

    ${value} =    Get Asset    cosmin
    Log    E-mail: ${value}

    [Teardown]    Delete Asset    cosmin
