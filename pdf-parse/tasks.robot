*** Settings ***
Documentation   PDF parsing tests.

Library    OperatingSystem
Library    RPA.PDF


*** Tasks ***
Email to document
    ${mail_data} =     Get File    devdata/mail.eml
    HTML to PDF    ${mail_data}    output/mail.pdf
