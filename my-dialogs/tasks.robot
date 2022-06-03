*** Settings ***
Documentation       Template robot main suite.

Library  RPA.Dialogs


*** Tasks ***
Minimal task
    FOR    ${counter}    IN RANGE    100
        Add heading    Input a number
        Add text input    number
        ${result}=    Run dialog
        ${valid_partnumber}=    Run Keyword And Return Status    Should Match Regexp    ${result.number}    	^\\d{6}$
        Exit For Loop If  $valid_partnumber
        Add icon    Warning    size=64
        Add Heading    Number must be six digits
    END
