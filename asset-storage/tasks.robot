*** Settings ***
Documentation       Asset Storage basic example.

Library    Collections
Library    RPA.Robocorp.Storage


*** Tasks ***
List All Assets
    @{assets} =    List Assets
    Log List    ${assets}

Store And Read Asset
    [Setup]    Set Text Asset    cosmin    cosmin@robocorp.com

    ${value} =    Get Text Asset    cosmin
    Log    E-mail: ${value}

    [Teardown]    Delete Asset    cosmin
