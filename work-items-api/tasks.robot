*** Settings ***
Documentation   Minimum set of tasks on using the entire cloud API given work items.

Library          RPA.Robocorp.WorkItems
Library          RPA.FileSystem
Library          OperatingSystem    WITH NAME    OS


*** Variables ***
${file_name}    file.txt
${other_file_name}    other_${file_name}
${devdata}    devdata


*** Keywords ***
Ensure fresh input work item
    ${bkp} =     Set Variable    ${devdata}${/}work-items.json
    ${witem} =     Set Variable    ${devdata}${/}work-items-in${/}input-items${/}work-items.json
    Copy File    ${witem}    ${OUTPUT_DIR}${/}work-items.json  # see how the work item looks like afterwards
    Copy File   ${bkp}    ${witem}  # refresh the in-use work item to previous state

# Adapter called methods under comments for each block.
Create work item
    [Arguments]    ${file_path}
    # `.create_output()`, `.add_file()`, `.save_payload()`
    Create Output Work Item
    Add Work Item File    ${file_path}    name=${file_name}
    Add Work Item File    ${file_path}    name=${other_file_name}
    Save Work Item

Log other file
    # `.get_file()`
    ${file_path} =    Get Work Item File    ${other_file_name}
    # Pass Execution    Passed in the middle of for earch work item
    Log    Path: ${file_path}

Log other file failure
    [Arguments]    ${a}    ${b}    ${total}=0
    ${result} =     Evaluate    ${a} + ${b}
    ${total} =    Convert To Integer    ${total}
    Should Be Equal    ${result}    ${total}

    Log other file
    Release Input Work Item    FAILED    exception_type=BUSINESS


*** Tasks ***
Work items coverage producer
    # <autoload input>, `.load_payload()`, `.list_files()`, `.save_payload()`
    Set Work Item Variable    extra    var
    Save Work Item

    # `.get_file()`
    ${file_path} =    Get Work Item File    ${file_name}
    Create work item    ${file_path}
    Create work item    ${file_path}

    # `.remove_file()`, `.save_payload()`, `.release_input()`
    Remove Work Item File    ${file_name}
    Save Work Item
    Release Input Work Item    DONE

Work items coverage consumer
    # `.release_input()`, `.reserve_input()`
    For Each Input Work Item    Log other file    return_results=False    items_limit=3

Work items coverage consumer failures
    # `.release_input()`, `.reserve_input()`
    # Log other file failure   1   2    total=3
    For Each Input Work Item    Log other file failure   1   2   3   return_results=False    items_limit=3

Work items variables
    ${variables} =    List work item variables
    Log    Available variables in work item: ${variables}
    
    Delete Work Item Variables    ${variables[0]}
    Save Work Item  # it's important to save, to be reflected in CR as well
    
    ${variables} =    List work item variables
    Log    Available variables in work item after removal of the initial one: ${variables}

    # When running locally, look in the output for the real state of the work-items.
    # When running in CR, just look in the initial input work item itself.
    [Teardown]  Ensure fresh input work item

Create output work item with variables and files
    &{customer_vars} =    Create Dictionary    user=Another3    mail=another3@company.com
    ${test_file} =      Set Variable    ${OUTPUT_DIR}${/}test.txt
    ${content} =    Set Variable    Test output work item
    RPA.FileSystem.Create File    ${test_file}   ${content}  overwrite=${True}
    Create Output Work Item     variables=${customer_vars}  files=${test_file}  save=${True}

    ${user_value} =     Get Work Item Variable      user
    Should Be Equal     ${user_value}      Another3

    ${path_out} =      Absolute Path   ${OUTPUT_DIR}${/}test-out.txt
    ${path} =   Get Work Item File  test.txt    path=${path_out}
    Should Be Equal    ${path}      ${path_out}
    OS.File should exist    ${path}
    ${obtained_content} =   Read File    ${path}
    Should Be Equal     ${obtained_content}      ${content}
