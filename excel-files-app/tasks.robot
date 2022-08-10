*** Settings ***
Documentation       Testing issues with handling Excel files/app and tables.

Library    Collections
Library    ExtendedExcelFiles    WITH NAME    ExcelFiles
Library    RPA.Excel.Application    WITH NAME    ExcelApp
Library    RPA.FileSystem
Library    RPA.JSON
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
    ExcelFiles.Open Workbook    ${destx}
    ${data} =    Read Worksheet    Sheet
    Log To Console    Initial table: ${data}
    Append Rows To Worksheet    ${content}    header=${True}
    Save Workbook
    ${data} =    Read Worksheet    Sheet
    Log To Console    Final table: ${data}
    Close Workbook


*** Tasks ***
Open and export excel file as PDF
    ExcelApp.Open Application    visible=${True}
    ExcelApp.Open Workbook    devdata${/}blank.xlsx
    ExcelApp.Export as PDF    ${OUTPUT_DIR}${/}blank.pdf
    ExcelApp.Quit Application


Transplant Column
    # Get the third column starting below "Col 3" row in the excel-1.xlsx file.
    ExcelFiles.Open Workbook    devdata${/}excel-1.xlsx
    ${subtable1} =    Read Worksheet As Table    name=Sheet 1    start=5
    ${col1} =    Get Table Column    ${subtable1}    C
    Log To Console    Column 1st file: ${col1}

    # Then get the same from the other file, but pick the second column.
    ExcelFiles.Open Workbook    devdata${/}excel-2.xlsx
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
    ExcelFiles.Open Workbook    devdata${/}emails.xlsx
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
    ${value} =    Evaluate    "2" + " "
    &{dict} =    Create Dictionary    A    1    B    ${value}
    ${table} =    Create Table    ${dict}
    Log List    ${table}

    Create Workbook    ${OUTPUT_DIR}${/}spaces.xlsx
    Append Rows To Worksheet    ${table}    header=${True}
    Save Workbook


Run Macro On Bad Name
    ExcelApp.Open Application    visible=${True}
    ExcelApp.Open Workbook    devdata${/}boldmacro-x.xlsm
    ExcelApp.Run Macro    bold_column
    Sleep    5s
    ExcelApp.Quit Application


Get Numbers Total
    @{numbers} =    Create List    ${194.40}    ${168.06}    ${77.57}
    ${total} =    Evaluate    sum($numbers)
    Log To Console    ${total}

    Create Workbook    ${OUTPUT_DIR}${/}numbers.xlsx    sheet_name=Numbers
    Set Cell Value    1    A    ${total}    fmt=0.00
    Save Workbook


Find Rows In Table
    ExcelFiles.Open Workbook    devdata${/}emails.xlsx

    ${table} =    Read Worksheet As Table    header=${True}    start=${2}
    ${results} =    Find Table Rows    ${table}    Age    >    ${1}
    Log To Console    Table: ${results}
    FOR    ${result}    IN    @{results}
        Log To Console    Row: ${result}
    END

    Filter Table By Column    ${table}    E-mail    not is    ${None}
    @{out} =    Export Table    ${table}    as_list=${True}
    Log To Console    Out: ${out}
    ${serialized} =    Convert JSON to String    ${out}  # list of dicts
    Log To Console    Serialized: ${serialized}


Append From First Empty Row
    # Add 50 rows in a 23 total rowed Excel file.
    @{rows} =    Create List
    FOR    ${counter}    IN RANGE    1    51
        &{row} =    Create Dictionary
        ...    Name      Cosmin
        ...    Age       29
        ...    E-mail    cosmin@robocorp.com
        Append To List    ${rows}    ${row}
    END

    ${workbook} =    Set Variable    ${OUTPUT_DIR}${/}emails.xlsx
    Copy File    devdata${/}emails.xlsx    ${workbook}
    ExcelFiles.Open Workbook    ${workbook}
    Append Rows to Worksheet    ${rows}    formatting_as_empty=${True}
    Save Workbook
