*** Settings ***
Documentation   PDF parsing tests.

Library    OperatingSystem
Library    RPA.PDF
Library    XML
Library    RPA.Robocorp.WorkItems


*** Variables ***
${invoice_file_name}    invoice.pdf


*** Keywords ***
PDF To Text Parse
    # Obtain text pages from PDF and write them in an output/pdf.txt file.
    [Arguments]    ${pdf}

    ${text_dict} =    Get Text From Pdf    ${pdf}
    Log    ${text_dict}
    @{pages} =    Set Variable    ${text_dict.values()}
    ${text_out} =     Set Variable    ${OUTPUT_DIR}${/}pdf.txt
    Create File    ${text_out}    overwrite=True
    FOR    ${page}    IN    @{pages}
        Append To File    ${text_out}    ${page}
        Append To File    ${text_out}    ${\n}${\n}${\n}${\n}
    END

PDF To XML Parse
    # Obtain the XML element object from PDF and write it in an output/pdf.xml file.
    [Arguments]    ${pdf}

    ${xml} =     Dump PDF as XML    ${pdf}
    Log    ${xml}
    Should Not Be Empty    ${xml}
    ${elem} =    Parse Xml    ${xml}
    Log    ${elem}
    Save Xml    ${elem}    ${OUTPUT_DIR}${/}pdf.xml


*** Tasks ***
Email To Document
    ${mail_data} =     Get File    devdata${/}mail.eml
    HTML to PDF    ${mail_data}    ${OUTPUT_DIR}${/}mail.pdf

PDF To Document Parse
    # Get path to input PDF file from input work item.
    ${pdf} =     Get Work Item File    ${invoice_file_name}

    PDF To Text Parse    ${pdf}
    PDF To XML Parse     ${pdf}
