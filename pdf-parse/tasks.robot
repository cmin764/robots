*** Settings ***
Documentation    PDF parsing tests.
Task Teardown    Close All Pdfs

Library    OperatingSystem
Library    RPA.FileSystem
Library    RPA.PDF
Library    Collections
Library    String

*** Variables ***
${invoice_file_name}    invoice.pdf
${boost_plm_invoice}    devdata/work-items-in/boost-plm/boost-plm-invoice.pdf


*** Keywords ***
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
