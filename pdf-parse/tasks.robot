*** Settings ***
Documentation    E-mail HTML to Docx conversion tests.

Library    OperatingSystem
Library    RPA.Email.ImapSmtp
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems
Library    MailParse  # local Python library
Library    wk-html2pdf

Variables    Variables.py


*** Keywords ***
Email To HTML
    [Arguments]    ${input_path}

    ${mail_data} =     Get File    ${input_path}
    ${mail_dict} =     Email To Dictionary    ${mail_data}    validate=False
    ${mail_html} =     Set Variable    ${mail_dict}[Body]
    [Return]    ${mail_html}

Local Email To Document
    [Arguments]    ${input_path}    ${output_path}
    ${mail_html} =    Email To HTML    ${input_path}

    RPA.FileSystem.Create File    ${output_path}.html    ${mail_html}    overwrite=True
    Html To Docx    ${mail_html}    ${output_path}


*** Tasks ***
Convert email to docx
    ${mail_file} =     Get Work Item File    mail.eml
    # Local Email To Document    ${mail_file}    ${OUTPUT_DIR}${/}mail.docx
    Email To Document    ${mail_file}    ${OUTPUT_DIR}${/}mail.docx

Convert email to PDF
    ${mail_file} =     Get Work Item File    mail.eml
    ${mail_html} =    Email To HTML    ${mail_file}
    ${html_file} =    Set Variable     ${OUTPUT_DIR}${/}mail.html
    RPA.FileSystem.Create File    ${html_file}    ${mail_html}    overwrite=True
    Convert HTML File To PDF    ${html_file}    ${OUTPUT_DIR}${/}mail.pdf    ${WK_PATH}
