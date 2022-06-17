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


Validate traffic data
    &{traffic_data} =    Create Dictionary    country=ISR    year=${2019}    rate=${3.9}
    ${country} =    Get Value From Json    ${traffic_data}    $.country
    ${valid} =    Evaluate    len("${country}") == 3
    Log    Valid: ${valid}
