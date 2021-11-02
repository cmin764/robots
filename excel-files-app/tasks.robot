*** Settings ***
Documentation       Testing issues with handling Excel files.
Library             RPA.Excel.Application
Task Setup          Open Application    visible=True
Task Teardown       Quit Application


*** Tasks ***
Open and export excel file as PDF
    Open Workbook    devdata/blank.xlsx
    Export as PDF    output/blank.pdf
