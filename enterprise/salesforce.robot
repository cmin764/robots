*** Settings ***
Documentation       Enterprise API library usage examples. (usually testing bugs)

Library             RPA.Robocorp.Vault
Library             RPA.Salesforce
Library             RPA.Tables

Suite Setup         Authenticate


*** Keywords ***
Authenticate
    ${secret} =    Get Secret    salesforce_cosmin
    Auth With Token
    ...    ${secret}[username]
    ...    ${secret}[password]
    ...    ${secret}[token]


*** Tasks ***
Query Empty Result As Table
    ${acc_id} =    Set Variable    '0017Q00000MTmkiQAE'  # '0017Q00000MTmkiQAD'
    ${query} =    Set Variable
    ...    SELECT Name FROM Opportunity WHERE AccountId = ${acc_id}

    ${result} =    Salesforce Query    ${query}    as_table=${True}
    Log To Console    ${result}

    ${result} =    Salesforce Query Result As Table    ${query}
    Log To Console    ${result}
    Write Table To CSV    ${result}    ${OUTPUT_DIR}/rows.csv
