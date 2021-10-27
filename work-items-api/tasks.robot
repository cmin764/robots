*** Settings ***
Documentation   Minimum set of tasks on using the entire cloud API given work items.

Library          RPA.Robocorp.WorkItems


*** Variables ***
${file_name}    file.txt
${other_file_name}    other_${file_name}


*** Keywords ***
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
    Log    ${file_path}

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
