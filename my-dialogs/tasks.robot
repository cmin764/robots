*** Settings ***
Documentation       Dialogs working with Work Items. (Unadvised!)

Library    RPA.Dialogs
Library    RPA.Robocorp.WorkItems


*** Tasks ***
Dialogs And Work Items
    ${msg} =    Get Work Item Variable    message

    FOR    ${counter}    IN RANGE    100
        Add heading    From Work Item: ${msg}
        Add heading    Input a number
        Add text input    number
        ${result} =    Run dialog
        ${is_valid} =    Run Keyword And Return Status
        ...    Should Match Regexp    ${result.number}    	^\\d{6}$
        IF    ${is_valid}    BREAK

        Add icon    Warning    size=${64}
        Add Heading    Number must be six digits
    END
