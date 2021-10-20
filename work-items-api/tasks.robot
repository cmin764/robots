*** Settings ***
Documentation   Minimum set of tasks on using the entire cloud API given work items.

Library          RPA.Robocorp.WorkItems


*** Variables ***
${file_name}    file.txt


*** Tasks ***
Work items coverage
    # Adapter called methods under comments for each block.

    # `.load_payload()`, `.list_files()`, `.save_payload()`
    Set Work Item Variable    extra    var
    Save Work Item

    # `.get_file()`, `.add_file()`, `.create_output()`, `.save_payload()`
    ${file_path} =    Get Work Item File    ${file_name}
    Create Output Work Item
    Add Work Item File    ${file_path}    name=${file_name}
    Add Work Item File    ${file_path}    name=other_${file_name}
    Save Work Item

    # `.remove_file()`, `.release_input()`
    Remove Work Item File    ${file_name}
    Save Work Item
    Release Input Work Item    DONE
