*** Settings ***
Documentation    E-mail HTML to Docx conversion tests.

Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems
Library    MailParse  # local Python library


*** Tasks ***
Email To Document
    ${mail_file} =     Get Work Item File    mail.eml
    ${mail_data} =     Get File    ${mail_file}
    ${mail_dict} =     Email To Dictionary    ${mail_data}
    ${mail_html} =     Set Variable    ${mail_dict}[Body]

    RPA.FileSystem.Create File    ${OUTPUT_DIR}${/}mail.html    ${mail_html}    overwrite=True
    Html To Docx    ${mail_html}    ${OUTPUT_DIR}${/}mail.docx
