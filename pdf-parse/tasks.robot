*** Settings ***
Documentation    PDF parsing tests.
Task Teardown    Close All Pdfs

Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.PDF
Library    RPA.Robocorp.WorkItems
Library    XML
Library    MailParse  # local library
Library    Collections
Library    String

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


Boost PLM parse invoice on page
    [Arguments]    ${page}
    &{items} =     Create Dictionary

    # Getting customer references below "Tariff Code".
    ${tariff_matches_down} =    Find Text    regex:.*Tariff Code.*    direction=down    pagenum=${page}    closest_neighbours=1
    FOR    ${index}    ${match}    IN ENUMERATE    @{tariff_matches_down}
        ${customer_ref} =     Set Variable    ${match.neighbours}[0]
        ${contains_tariff} =    Run Keyword And Return Status    Should Contain    ${customer_ref}    Tariff Code:
        IF    ${contains_tariff}
            @{lines} =     Split To Lines    ${match.anchor}    1
            ${customer_ref} =    Set Variable    ${lines}[0]
        END

        ${match_no} =     Convert To String    ${index}
        &{item} =     Create Dictionary    customer_ref=${customer_ref}
        Set To Dictionary    ${items}    ${match_no}=${item}
    END

    # Getting material number and description above "Tariff Code".
    ${tariff_matches_up} =    Find Text    regex:.*Tariff Code.*    direction=up    pagenum=${page}    closest_neighbours=4
    FOR    ${index}    ${match}    IN ENUMERATE    @{tariff_matches_up}
        ${material_pos} =    Set Variable    3
        ${first_neighbour} =    Set Variable    ${match.neighbours}[0]
        ${contains_item_no} =    Run Keyword And Return Status    Should Contain    ${first_neighbour}    ITEM NO.
        ${contains_tariff} =     Run Keyword And Return Status    Should Contain    ${first_neighbour}    Tariff Code:
        IF    ${contains_item_no}
            ${material_pos} =    Set Variable    1
        ELSE IF   ${contains_tariff}
            ${material_pos} =    Set Variable    2
        END
        ${material} =     Set Variable    ${match.neighbours}[${material_pos}]
        @{material_split} =     Split To Lines    ${material}

        ${match_no} =     Convert To String    ${index}
        ${item} =    Get From Dictionary    ${items}    ${match_no}
        Set To Dictionary    ${item}    material_no=${material_split}[0]    material_descr=${material_split}[1]
    END

    # Getting the quantities in the page in order below "QTY" column header.
    ${items_length} =     Get Length    ${items}
    ${quantity_matches} =    Find Text    regex:QTY    direction=bottom    pagenum=${page}    closest_neighbours=${items_length}    regexp=\\d+$
    ${quantity_match} =     Set Variable    ${quantity_matches}[0]
    ${offset} =     Set Variable    ${0}
    @{qty_parts} =     Split To Lines    ${quantity_match.anchor}
    ${qty_parts_len} =    Get Length    ${qty_parts}
    IF    ${qty_parts_len} == 2
        # The first quantity value is included in the anchor text box.
        ${item} =    Get From Dictionary    ${items}    0
        Set To Dictionary    ${item}    quantity=${qty_parts}[1]
        ${offset} =     Set Variable    ${1}
    END

    FOR    ${index}    ${qty}    IN ENUMERATE    @{quantity_matches[0].neighbours}
        ${index} =     Evaluate    ${index} + ${offset}
        ${match_no} =     Convert To String    ${index}
        ${item} =    Get From Dictionary    ${items}    ${match_no}
        Set To Dictionary    ${item}    quantity=${qty}
    END

    [Return]    ${items}


*** Tasks ***
Email To Document
    ${mail_data} =     Get File    devdata${/}bce.eml
    ${mail_dict} =     Email To Dictionary    ${mail_data}
    ${mail_html} =     Set Variable    ${mail_dict}[Body]

    RPA.FileSystem.Create File    ${OUTPUT_DIR}${/}mail.html    ${mail_html}    overwrite=True

    ${mail_html} =     Get File    ${OUTPUT_DIR}${/}mail.html

    # This needs more work on validation and the output doesn't look right.
    # HTML to PDF    ${mail_html}    ${OUTPUT_DIR}${/}mail.pdf

    Html To Docx    ${mail_html}    ${OUTPUT_DIR}${/}mail.docx

PDF To Document Parse
    # Get path to input PDF file from input work item.
    ${pdf} =     Get Work Item File    ${invoice_file_name}
    # ${pdf} =     Set Variable     invoice.pdf

    # PDF To Text Parse    ${pdf}
    PDF To XML Parse     ${pdf}

Boost PLM Invoice Parsing
    Open Pdf     ${boost_plm_invoice}
    FOR    ${page}    IN RANGE    1    3
        ${items} =    Boost PLM parse invoice on page    ${page}
        # Logs a dictionary with items where the key is the position of the item in the
        # page and the value is a dictionary with these keys:
        # - customer_ref
        # - material_no
        # - material_descr
        # - quantity
        Log Dictionary    ${items}
    END


Unicode HTML To PDF
    ${template_html_file} =    Set Variable    devdata${/}template.html
    ${output_pdf_file} =       Set Variable    ${OUTPUT_DIR}${/}template-filled.pdf

    RPA.FileSystem.Create File    ${template_html_file}    <h2><b><i>{{name}}</b></i></h2><br>normal<br><strong>strong</strong><br><em>em</em><br><i>italic</i><br><b>bold</b><br>    overwrite=${True}
    ${payload}    Create Dictionary    name=ĄĆĘŁŃÓŚŹŻąćęłńóśźżă
    Template Html To Pdf    ${template_html_file}    ${output_pdf_file}    variables=${payload}


PDF Invoice Parsing
    # Extract Data From First Page
    ${robo_report} =     Get Work Item File     report.pdf    ${OUTPUT_DIR}${/}report.pdf
    ${text} =    Get Text From PDF    ${robo_report}
    ${lines} =     Get Lines Matching Regexp    ${text}[${1}]    .+pain.+
    Log    ${lines}

    # Get Invoice Number
    ${robo_invoice} =     Get Work Item File    invoice.pdf
    Open Pdf    ${robo_invoice}
    ${matches} =  Find Text    Invoice Number
    Log List      ${matches}

    # Fill Form Fields
    ${robo_form} =     Get Work Item File    form.pdf
    Switch To Pdf    ${robo_form}
    ${fields} =     Get Input Fields   encoding=utf-16
    Log Dictionary    ${fields}
    Set Field Value    Given Name Text Box    Mark
    Save Field Values    output_path=${OUTPUT_DIR}${/}completed-form.pdf
    ...                  use_appearances_writer=${True}

    # Get text from Tesla annual report.
    ${robo_tesla} =     Get Work Item File    tesla.pdf
    Switch To Pdf    ${robo_tesla}
    ${matches} =     Find Text    regex:.*FORM 10-K.*    direction=down    pagenum=2
    Log Many    ${matches}
    ${matches} =     Find Text    regex:.*Form 10-K.*    direction=up    pagenum=301
    Log Many    ${matches}

Add watermark into PDF
    ${in_out_pdf} =     Set Variable    ${OUTPUT_DIR}${/}receipt.pdf
    RPA.FileSystem.Copy File    devdata${/}receipt.pdf    ${in_out_pdf}
    ${screenshot} =    Set Variable    devdata${/}robot.png
    Open Pdf    ${in_out_pdf}
    Add Watermark Image to PDF    ${screenshot}    ${in_out_pdf}

    ${dest} =     Set Variable    ${CURDIR}${/}receipt-moved.pdf
    Log To Console    ${dest}
    RPA.FileSystem.Move File    ${in_out_pdf}      ${dest}     overwrite=True

    ${dest_copy} =     Set Variable    ${CURDIR}${/}receipt-moved-copy.pdf
    OperatingSystem.Copy File    ${dest}  ${dest_copy}
    OperatingSystem.Move File    ${dest_copy}    ${in_out_pdf}
