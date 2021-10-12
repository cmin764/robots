*** Settings ***
Documentation    Testing the helper keyword on consuming all work items in the queue.
Library          RPA.Robocorp.WorkItems
Library          OperatingSystem


*** Keywords ***
Add Work Item
    # Get a file path from the current input work item payload.
    ${infile_path} =     Get Work Item Variable    infile

    # Create a new output work item which contains files attached to it.
    Create Output Work Item
    Add Work Item File    ${infile_path}    name=infile.txt
    Save Work Item


*** Tasks ***
Consume queue
    FOR    ${index}    IN RANGE    1024
        Add Work Item
        ${has_input} =     Run Keyword And Return Status    Get Input Work Item
        Exit For Loop If    not ${has_input}
    END
