*** Settings ***
Documentation       Testing issues with handling Excel files.
Library             RPA.Excel.Application    WITH NAME    App
Library             RPA.Excel.Files    WITH NAME    Files
Library             RPA.Tables  


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
    
    [Teardown]    Close Workbook

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
