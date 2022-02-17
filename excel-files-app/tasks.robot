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
