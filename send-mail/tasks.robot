*** Settings ***
Documentation       Test mail sending, mainly with Outlook.

Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.Outlook.Application

Task Setup              Open Application
Suite Teardown          Quit Application


*** Tasks ***
Save PDF From Outlook App
    ${name} =   Set Variable    exchange-oauth2
    ${ext} =    Set Variable    pdf
    @{files} =  Find Files  ${OUTPUT_DIR}${/}${name}*
    RPA.FileSystem.Remove Files    @{files}

    ${emails} =  Get Emails    email_filter=[Subject]='Duplicate attachment'
    FOR  ${email}  IN   @{emails}
        FOR  ${attachment}  IN  @{email}[Attachments]
            IF  ".pdf" in "${attachment}[filename]"
                # Double save to observe how duplication is resolved.
                Save Email Attachments    ${attachment}    ${OUTPUT_DIR}
                Save Email Attachments    ${attachment}    ${OUTPUT_DIR}
            END
        END
    END

    File Should Exist   ${OUTPUT_DIR}${/}${name}.${ext}
    File Should Exist   ${OUTPUT_DIR}${/}${name}-2.${ext}
