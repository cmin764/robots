*** Settings ***
Documentation       Test JSON keywords.

Library    OperatingSystem
Library    RPA.JSON
Library    String

Suite Setup     Ingest JSON


*** Variables ***
${JSON_STRING}      {
...                   "clients": [
...                     {
...                       "name": "Johnny Example",
...                       "email": "john@example.com",
...                       "orders": [
...                         {"address": "Streetroad 123", "state": "TX", "price": 103.20, "id":"guid-001"},
...                         {"address": "Streetroad 123", "state": "TX", "price": 98.99, "id":"guid-002"}
...                       ]
...                     },
...                     {
...                       "name": "Jane Example",
...                       "email": "jane@example.com",
...                       "orders": [
...                         {"address": "Waypath 321", "state": "WA", "price": 22.00, "id":"guid-003"},
...                         {"address": "Streetroad 123", "state": "TX", "price": 2330.01, "id":"guid-004"},
...                         {"address": "Waypath 321", "state": "WA", "price": 152.12, "id":"guid-005"}
...                       ]
...                     }
...                   ]
...                 }

${ID}               guid-003


*** Keywords ***
Delete Value
    [Arguments]    ${string}
    &{before} =    Convert string to JSON    ${string}
    ${expr} =    Set Variable    $.People[?(@..Name=="Mark")]
    ${marks} =     Get values from JSON    ${before}    ${expr}
    Log To Console    ${marks}
    &{after} =     Delete from JSON    ${before}    ${expr}
    Log To Console    ${after}

Ingest JSON
    ${doc}=    Convert string to json    ${JSON_STRING}
    Set suite variable    ${JSON_DOC}    ${doc}


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


*** Tasks ***
Get All Prices and Order Ids
    # Arithmetic operations only work when lists are of equal lengths and types.
    ${prices}=    Get values from json
    ...    ${JSON_DOC}
    ...    $.clients[*].orders[*].id + " has price " + $.clients[*].orders[*].price.`str()`
    Log    \nOUTPUT IS\n ${prices}    console=${True}
    Should be equal as strings    ${prices}
    ...    ['guid-001 has price 103.2', 'guid-002 has price 98.99', 'guid-003 has price 22.0', 'guid-004 has price 2330.01', 'guid-005 has price 152.12']

Find Only Valid Emails With Regex
    # The regex used in this example is simplistic and
    # will not work with all email addresses
    ${emails}=    Get values from json
    ...    ${JSON_DOC}
    ...    $.clients[?(@.email =~ "[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]+")].email
    Log    \nOUTPUT IS\n ${emails}    console=${True}
    Should be equal as strings    ${emails}    ['john@example.com', 'jane@example.com']

Find Orders From Texas Over 100
    # The regex used in this example is simplistic and
    # will not work with all email addresses
    ${orders}=    Get values from json
    ...    ${JSON_DOC}
    ...    $.clients[*].orders[?(@.price > 100 & @.state == "TX")]
    Log    \nOUTPUT IS\n ${orders}    console=${True}
    Should be equal as strings    ${orders}
    ...    [{'address': 'Streetroad 123', 'state': 'TX', 'price': 103.2, 'id': 'guid-001'}, {'address': 'Streetroad 123', 'state': 'TX', 'price': 2330.01, 'id': 'guid-004'}]
