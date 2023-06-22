*** Settings ***
Documentation       Asset Storage example

Library    Collections
Library    OperatingSystem
Library    RPA.Robocorp.Storage

Suite Setup    Set Workspace


*** Variables ***
${WORKSPACE}    4f107208-5f4b-47f2-a510-79936169aa8e  # CI: Proof of Consepts


*** Keywords ***
Set Workspace
    Log Environment Variables
    ${local_run} =    Get Environment Variable    LOCAL_RUN    ${EMPTY}
    IF    "${local_run}"
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
