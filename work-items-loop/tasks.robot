*** Settings ***
Documentation    Testing the helper keyword on consuming all work items in the queue.
Library          RPA.Robocorp.WorkItems
Library          OperatingSystem


*** Keywords ***
Add Work Item
    # Get a file from the current input work item.
    ${path} =        Get Work Item File    orders.txt
    Log To Console    Getting: ${path}
    ${content} =     Get File    ${path}

    # Create a new output work item which doesn't contain files attached to it.
    Create Output Work Item
    Set work item variables    doesnt=matter
    Save Work Item

    # Release and return content.
    Release Input Work Item    DONE
    [Return]    ${content}


*** Tasks ***
Consume queue
    # This block can run with any kind of work item.
    Log Environment Variables
    ${payload} =     Get Work Item Payload
    Log    ${payload}
    
    # This block runs with work items which have files attached to them.
    @{results} =     For Each Input Work Item    Add Work Item
    Log    ${results}
