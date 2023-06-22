*** Settings ***
Documentation       Asset Storage example

Library    Collections
Library    OperatingSystem
Library    RPA.Robocorp.Storage
Library    RPA.Robocorp.Vault
Library    String

Suite Setup    Prepare Environment


*** Variables ***
${WORKSPACE}    4f107208-5f4b-47f2-a510-79936169aa8e  # CI: Proof of Consepts


*** Keywords ***
Prepare Environment
    ${secret} =    Get Secret    asset_storage
    Set Environment Variable    RC_API_KEY    ${secret}[api_key]

    ${local_run} =    Get Environment Variable    LOCAL_RUN    ${EMPTY}
    IF    "${local_run}"
        Set Environment Variable    RC_WORKSPACE_ID    ${WORKSPACE}
    ELSE
        # Temporary in-robot fix until the `AUTHENTICATION_SCHEME_NOT_IMPLEMENTED` gets
        #  solved on the cloud side.
        # ${api_url} =    Get Environment Variable    RC_API_URL_V1
        # ${api_url} =    Replace String    ${api_url}  robocorp.dev/v1  robocloud.dev
        # Set Environment Variable    RC_API_URL_V1    ${api_url}
        Remove Environment Variable    RC_API_TOKEN_V1  # to enable API key based auth
    END
    Log Environment Variables  # remove this in production to not expose your secrets


*** Tasks ***
List All Assets
    @{assets} =    List Assets
    Log List    ${assets}

Store And Read Asset
    [Setup]    Set Asset    cosmin    cosmin@robocorp.com

    ${value} =    Get Asset    cosmin
    Log    E-mail: ${value}

    [Teardown]    Delete Asset    cosmin
