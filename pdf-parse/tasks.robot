*** Settings ***
Documentation    E-mail HTML to Docx conversion tests.

Library    OperatingSystem
Library    RPA.Email.ImapSmtp
Library    RPA.FileSystem
Library    RPA.Robocorp.WorkItems
Library    MailParse  # local Python library


*** Keywords ***
Local Email To Document
    [Arguments]    ${input_path}    ${output_path}
    ${mail_data} =     Get File    ${input_path}
    ${mail_dict} =     Email To Dictionary    ${mail_data}    validate=False
    ${mail_html} =     Set Variable    ${mail_dict}[Body]

    RPA.FileSystem.Create File    ${output_path}.html    ${mail_html}    overwrite=True
    Html To Docx    ${mail_html}    ${output_path}


*** Tasks ***
Convert email to docx
    ${mail_file} =     Get Work Item File    mail.eml
    Local Email To Document    ${mail_file}    ${OUTPUT_DIR}${/}mail.docx
    # Email To Document    ${mail_file}    ${OUTPUT_DIR}${/}mail.docx
