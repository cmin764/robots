*** Settings ***
Documentation       Dialogs working with work items.

Library    RPA.Dialogs
Library    RPA.Robocorp.WorkItems


*** Tasks ***
Minimal task
    ${msg} =    Get Work Item Variable    message

    FOR    ${counter}    IN RANGE    100
        Add heading    From Work Item: ${msg}
        Add heading    Input a number
        Add text input    number
        ${result}=    Run dialog
        ${valid_partnumber}=    Run Keyword And Return Status    Should Match Regexp    ${result.number}    	^\\d{6}$
        Exit For Loop If  $valid_partnumber
        Add icon    Warning    size=64
        Add Heading    Number must be six digits
    END
