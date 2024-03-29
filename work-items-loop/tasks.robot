*** Settings ***
Documentation    Testing the helper keyword on consuming all work items in the queue.

Library        Collections
Library        MyLibrary
Library        OperatingSystem
Library        RPA.Robocorp.WorkItems

Suite Setup    Fail On Zero


*** Keywords ***
Add work item with attached file
    # Get a file path from the current input work item payload.
    ${infile_path} =     Get Work Item Variable    infile

    # Create a new output work item which contains a file attached to it.
    Create Output Work Item
    Add Work Item File    ${infile_path}    name=infile.txt
    Save Work Item


Read files and save content in payload
    ${path} =     Get Work Item File    orders.txt
    ${content} =     Get File    ${path}

    Create Output Work Item
    Set Work Item Variable    data    ${content}
    Save Work Item

    [Return]    ${content}


Process Item
    ${value} =    Get Work Item Variable    var
    Log To Console    Processing item value: ${value}
    IF    ${value} == ${2}  # make it fail if `var` is 2
        Fail    Work Item with variable value ${value} failed
        # Fail Func
        # ${status}    ${msg} =    Run Keyword And Ignore Error
        # ...    Fail    Work Item variable 2 failed
        # Log    ${msg}
    END
    RETURN    ${value}


Fail On Zero
    ${status}    ${value} =    Run Keyword And Ignore Error
    ...    Get Work Item Variable    var
    IF    "${status}" == "FAIL"    RETURN
    
    Log To Console    Setup value: ${value}
    IF    ${value} == ${0}
        Fail    Initial Work Item failed because of zero value
    END


*** Tasks ***
Get inputs and create outputs using file paths from payload
    FOR    ${index}    IN RANGE    1024
        Add work item with attached file
        ${has_input} =     Run Keyword And Return Status    Get Input Work Item
        Exit For Loop If    not ${has_input}
    END


Get inputs and create outputs using file paths from payload with helper
    For Each Input Work Item    Add work item with attached file    return_results=False


Read work item with attached file and add content as payload
    @{contents} =    For Each Input Work Item    Read files and save content in payload
    Log Many    @{contents}


Get payload given e-mail process triggering
    ${mail} =    Get Work Item Variable    parsedEmail
    Log    ${mail}
    Set Work Item Variables    &{mail}[Body]
    Save Work Item
    ${message} =     Get Work Item Variable     message
    Should Be Equal     ${message}      from email


Failing Work Item On Task Or Setup
    @{values} =    For Each Input Work Item    Process Item
    Log List    ${values}
