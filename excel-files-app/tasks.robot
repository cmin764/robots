*** Settings ***
Documentation       Testing issues with handling Excel files.

Library    Collections
Library    RPA.Excel.Application    WITH NAME    App
Library    RPA.Excel.Files    WITH NAME    Files
Library    RPA.FileSystem
Library    RPA.Tables
Library    String

Suite Teardown    Close Workbooks


*** Keywords ***
Close Workbooks
    Close Workbook
    Close Document


Append Content To Sheet
    [Arguments]    ${excel_file}    ${content}
    Log To Console    Excel: ${excel_file}
    ${srcx} =    Set Variable    devdata${/}${excel_file}
    ${destx} =    Set Variable    ${OUTPUT_DIR}${/}${excel_file}
    Copy File    ${srcx}    ${destx}
    Files.Open Workbook    ${destx}
    ${data} =    Read Worksheet    Sheet
    Log To Console    Initial table: ${data}
    Append Rows To Worksheet    ${content}    header=${True}
    Save Workbook
    ${data} =    Read Worksheet    Sheet
    Log To Console    Final table: ${data}
    Close Workbook


*** Tasks ***
Open and export excel file as PDF
    App.Open Application    visible=True
    App.Open Workbook    devdata/blank.xlsx
    App.Export as PDF    output/blank.pdf
    App.Quit Application


Transplant Column
    # Get the third column starting below "Col 3" row in the excel-1.xlsx file.
    Files.Open Workbook    devdata${/}excel-1.xlsx
    ${subtable1} =    Read Worksheet As Table    name=Sheet 1    start=5
    ${col1} =    Get Table Column    ${subtable1}    C
    Log To Console    Column 1st file: ${col1}

    # Then get the same from the other file, but pick the second column.
    Files.Open Workbook    devdata${/}excel-2.xlsx
    ${subtable2} =    Read Worksheet As Table    name=Sheet 1    start=5
    ${col2} =    Get Table Column    ${subtable2}    B
    Log To Console    Column 2nd file before: ${col2}
    # And set the column of the initial file into another column of the last file.
    Set Table Column    ${subtable2}    B    ${col1}  # pay attention on how this works
    ${col2} =    Get Table Column    ${subtable2}    B
    Log To Console    Column 2nd file after: ${col2}

    # Finally, write the newly obtained table into the last excel on another sheet.
    Create Worksheet    Sheet 2    ${subtable2}    exist_ok=${True}
    Save Workbook


Remove rows with empty cells
    # Open Excel and read "Sheet 1" as table.
    Files.Open Workbook    devdata${/}emails.xlsx
    ${table} =    Read Worksheet As Table    name=Sheet 1    start=3  # avoiding some headers
    ${emails} =     Get Table Column    ${table}    C  # e-mails on third column
    
    # Iterate the rows bottom top so each time we pop out one row, the rest of the
    #  rows positions wouldn't be affected. (if you traverse top -> bottom, then
    #  removing a row will make the ones beneath move up by one position... and that
    #  would add complexity to index computation)
    ${rows_count} =    Get Length    ${emails}
    # Starts from last row and ends on the first one (index: 0).
    FOR    ${index}    IN RANGE    ${rows_count - 1}    -1    -1
        ${email} =     Set Variable    ${emails}[${index}]
        Log To Console    ${index}: ${email}
        IF    "${email}" == "${None}"
            Pop Table Row    ${table}    row=${index}
        END
    END
    
    # Now the table is shortened by the rows which don't contain an E-mail value.
    Log To Console    ${table}
    ${emails} =     Get Table Column    ${table}    C
    Log To Console    ${emails}


Test single row sheet
    # "Single" in this case acts like header for a 1x1 table.
    &{row} =    Create Dictionary    Single    Test
    @{content} =    Create List    ${row}

    Append Content To Sheet    one-row.xlsx    ${content}
    Append Content To Sheet    one-row.xls    ${content}
    Append Content To Sheet    empty.xlsx    ${content}
    Append Content To Sheet    empty.xls    ${content}


Export CSV Table To Excel
    # Strip the junk at the beginning of the CSV file.
    ${csv_in_path} =    Set Variable    devdata${/}peter-header-row.csv
    ${data_in} =    Read File    ${csv_in_path}
    @{lines_in} =    Split To Lines    ${data_in}
    FOR    ${start}    ${line}    IN ENUMERATE    @{lines_in}
        ${contains} =    Run Keyword And Return Status    Should Contain
        ...    ${line}    Customer Account #
        IF    ${contains}    BREAK
    END
    # Put the good lines only in a new CSV file.
    ${csv_out_path} =    Set Variable    ${OUTPUT_DIR}${/}peter-header-row.csv
    @{lines_out} =    Get Slice From List    ${lines_in}    ${start}
    ${data_out} =    Catenate    SEPARATOR=${\n}    @{lines_out}
    ${data_out} =    Replace String    ${data_out}    "    ${EMPTY}
    Create File    ${csv_out_path}    ${data_out}    overwrite=${True}

    ${table} =    Read table from CSV    ${csv_out_path}
    ...    header=${True}    delimiters=,
    Create Workbook    ${OUTPUT_DIR}${/}peter-header-row.xlsx
    Append Rows To Worksheet    ${table}    header=${True}
    Save Workbook


Test Trailing Spaces
    Create Workbook    ${OUTPUT_DIR}${/}spaces.xlsx
    ${value} =    Evaluate    "x" + " "
    &{dict} =    Create Dictionary    A    1    B    ${value}
    ${table} =    Create Table    ${dict}
    Log To Console    ${table}
    Append Rows To Worksheet    ${table}    header=${True}
    Save Workbook
