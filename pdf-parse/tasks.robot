*** Settings ***
Documentation    PDF parsing tests.
Task Teardown    Close All Pdfs

Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.PDF
Library    RPA.Robocorp.WorkItems
Library    XML
Library    MailParse  # local library


*** Variables ***
${invoice_file_name}    invoice.pdf
${boost_plm_invoice}    devdata/work-items-in/boost-plm/boost-plm-invoice.pdf


*** Keywords ***
PDF To Text Parse
    # Obtain text pages from PDF and write them in an output/pdf.txt file.
    [Arguments]    ${pdf}

    ${text_dict} =    Get Text From Pdf    ${pdf}
    Log    ${text_dict}
    @{pages} =    Set Variable    ${text_dict.values()}
    ${text_out} =     Set Variable    ${OUTPUT_DIR}${/}pdf.txt
    RPA.FileSystem.Create File    ${text_out}    overwrite=True
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
    ${mail_dict} =     Email To Dictionary    ${mail_data}
    ${mail_html} =     Set Variable    ${mail_dict}[Body]
    RPA.FileSystem.Create File    ${OUTPUT_DIR}${/}mail.html    ${mail_html}    overwrite=True
    # HTML to PDF    ${mail_dict}[Body]    ${OUTPUT_DIR}${/}mail.pdf

PDF To Document Parse
    # Get path to input PDF file from input work item.
    ${pdf} =     Get Work Item File    ${invoice_file_name}
    # ${pdf} =     Set Variable     invoice.pdf

    # PDF To Text Parse    ${pdf}
    PDF To XML Parse     ${pdf}

Boost PLM Invoice Parsing
    Open Pdf     ${boost_plm_invoice}

    ${customer} =    Find Text    uty tariff code:    direction=bottom    pagenum=1
    Log    ${customer}
