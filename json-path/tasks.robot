*** Settings ***
Documentation       Test JSON keywords.

Library    RPA.JSON


*** Keywords ***
Delete Value
    [Arguments]    ${string}
    &{before} =    Convert string to JSON    ${string}
    ${expr} =    Set Variable    $.People[?(@..Name=="Mark")]
    ${marks} =     Get values from JSON    ${before}    ${expr}
    Log To Console    ${marks}
    &{after} =     Delete from JSON    ${before}    ${expr}
    Log To Console    ${after}


*** Tasks ***
Delete Values
    Delete Value    {"People": [{"Name": "Mark", "Email": "mark@robocorp.com"}, {"Name": "Jane", "Extra": 1}]}
    Delete Value    {"People": {"a": 1, "b": {"Name": "Mark", "Email": "mark@robocorp.com"}, "c": {"Name": "Jane", "Extra": 1}}}
    Delete Value    {"People": {"a": 1, "b": {"z": {"Name": "Mark", "Email": "mark@robocorp.com"}}, "c": {"Name": "Jane", "Extra": 1}}}
