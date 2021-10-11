*** Settings ***
Documentation    Testing the helper keyword on consuming all work items in the queue.
Library          RPA.Robocorp.WorkItems
Library          OperatingSystem
Library          Collections


*** Variables ***
${idx}    ${1}


*** Keywords ***
Add Work Item
    [Arguments]  ${counter}

    # Get files from the current input work item.
    ${path} =        Get Work Item File    orders.txt
    Log To Console    Getting: ${path}
    ${content} =     Get File    ${path}

    # Save a new file with the same content into one adjacent output work item.
    Create Output Work Item
    Set work item variables    name=CustomName${counter}   id=${counter}
    #Add Work Item File    devdata/orders${counter}.txt    name=orders.txt
    Save Work Item
    [Return]    ${content}

Add Work Item Wrapper
    ${ret} =    Add Work Item    ${idx}
    Set Global Variable    ${idx}    ${idx + 1}

    # Any of these would fail if uncommented
    # Get Input Work Item
    # @{results} =     For Each Input Work Item    Add Work Item Wrapper

    Release Input Work Item    DONE
    
    # Any of these would fail if uncommented
    # Release Input Work Item    DONE
    # Create Output Work Item
    [Return]    ${ret}


*** Tasks ***
Consume queue
    Log Environment Variables
    @{results} =     For Each Input Work Item    Add Work Item Wrapper
    Log List    ${results}
