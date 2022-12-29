*** Settings ***
Documentation       Test JSON keywords.

Library    OperatingSystem
Library    RPA.JSON
Library    String


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
    Log To Console    Output: ${OUTPUT_DIR}
    Log To Console    Artifacts: %{ROBOT_ARTIFACTS}
    Log Environment Variables


JSON Add Value
    @{acuerdos} =     Create List
    &{data_dict} =    Create Dictionary
    ...    my    data    acuerdos    ${acuerdos}
    ...    numeroAcuerdo    ${2}
    &{item} =    Create Dictionary    reqData    ${data_dict}

    &{acuerdo} =       Create Dictionary
        ...            numeroAcuerdo                  ${1}
        ...            fechaCreacionAcuerdo           19-07-2022
        ...            fechaEnviadoBeneficario        19-07-2022
        ...            errorCreacion                  Mensaje de Error
    Log To Console   ${item}[reqData]
    ${after} =    Add to JSON    ${item}[reqData]    $    ${acuerdo}
    Log To Console   ${after}
    # {'my': 'data', 'acuerdos': [], 'numeroAcuerdo': 1, 'fechaCreacionAcuerdo': '19-07-2022', 'fechaEnviadoBeneficario': '19-07-2022', 'errorCreacion': 'Mensaje de Error'}

    Add to JSON    ${item}[reqData]    $.acuerdos    ${acuerdo}
    Log To Console   ${item}
    # {'reqData': {'my': 'data', 'acuerdos': [{'numeroAcuerdo': 1, 'fechaCreacionAcuerdo': '19-07-2022', 'fechaEnviadoBeneficario': '19-07-2022', 'errorCreacion': 'Mensaje de Error'}], 'numeroAcuerdo': 1, 'fechaCreacionAcuerdo': '19-07-2022', 'fechaEnviadoBeneficario': '19-07-2022', 'errorCreacion': 'Mensaje de Error'}}


Replace EOLs
    ${text} =    Set Variable    first\nsecond
    ${text} =    Replace String    ${text}    \n    ${\n}
    Log To Console    ${text}
