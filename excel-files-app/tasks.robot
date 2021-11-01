*** Settings ***
Documentation   Testing issues with handling Excel files.
Library    RPA.Excel.Application


*** Tasks ***
Open Excel File
    Open Application
    Open Workbook    devdata/blank.xlsx
