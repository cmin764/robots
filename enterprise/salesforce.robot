*** Settings ***
Documentation       Salesforce API examples.
...                 Prerequisites: See README.md

Library             Collections
Library             RPA.Robocorp.Vault
Library             RPA.Salesforce
Library             String
Library             RPA.Tables

Suite Setup         Authenticate
Task Setup          Generate random name


*** Tasks ***
Create a new Salesforce object (Opportunity)
    # Salesforce -> Setup -> Object Manager -> Opportunity -> Fields & Relationships.
    # Pass in data as a dictionary of object field names.
    ${account}=
    ...    Salesforce Query Result As Table
    ...    SELECT Id FROM Account WHERE Name = 'Burlington Textiles Corp of America'
    ${object_data}=
    ...    Create Dictionary
    ...    AccountId=${account}[0][0]
    ...    CloseDate=2022-02-22
    ...    Name=${RANDOM_NAME}
    ...    StageName=Closed Won
    ${object}=    Create Salesforce Object    Opportunity    ${object_data}
    ${opportunity}=    Get Salesforce Object By Id    Opportunity    ${object}[id]
    Log Dictionary    ${opportunity}

Query objects using Salesforce Object Query Language
    # Salesforce -> Documentation -> Example SELECT Clauses.
    # Salesforce -> Setup -> Object Manager -> <Type> -> Fields & Relationships.
    ${opportunity}=
    ...    Salesforce Query Result As Table
    ...    SELECT AccountId, Amount, CloseDate, Description, Name FROM Opportunity
    ${list}=    Export Table    ${opportunity}
    Log List    ${list}

Describe a Salesforce object by type
    ${description}=    Describe Salesforce Object    Opportunity
    Log Dictionary    ${description}

Describe all picklist values for a Salesforce object field
    ${description}=    Describe Salesforce Object    Opportunity
    FOR    ${field}    IN    @{description}[fields]
        IF    "${field}[name]" == "StageName"
            Log List    ${field}[picklistValues]
        END
    END

Get the metadata for a Salesforce object
    ${metadata}=    Get Salesforce Object Metadata    Opportunity
    Log Dictionary    ${metadata}


*** Keywords ***
Authenticate
    ${secret}=    Get Secret    salesforce_cosmin
    Auth With Token
    ...    ${secret}[username]
    ...    ${secret}[password]
    ...    ${secret}[token]

Generate random name
    ${random_string}=    Generate Random String
    Set Suite Variable    ${RANDOM_NAME}    Random name ${random_string}
