*** Settings ***
Documentation    Testing the helper keyword on consuming all work items in the queue.
Library          RPA.Robocorp.WorkItems
Library          OperatingSystem


*** Keywords ***
Add work item with attached file
    # Get a file path from the current input work item payload.
    ${infile_path} =     Get Work Item Variable    infile

    # Create a new output work item which contains a file attached to it.
    Create Output Work Item
    Add Work Item File    ${infile_path}    name=infile.txt
    Save Work Item


*** Tasks ***
Get inputs and create outputs using file paths from payload
    FOR    ${index}    IN RANGE    1024
        Add work item with attached file
        ${has_input} =     Run Keyword And Return Status    Get Input Work Item
        Exit For Loop If    not ${has_input}
    END
