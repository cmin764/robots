*** Settings ***
Documentation       Testing issues with handling Excel files.
Library             RPA.Excel.Application
Task Setup          Open Application    visible=True
Task Teardown       Quit Application


*** Tasks ***
Open Excel File
    Open Workbook    devdata/blank.xlsx
    Export as PDF    output/blank.pdf
