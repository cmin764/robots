*** Settings ***
Documentation   PDF parsing tests.

Library    OperatingSystem
Library    RPA.PDF
Library    XML


*** Variables ***
${boost_invoice}    devdata${/}sensitive${/}boost-plm-invoice.pdf


*** Tasks ***
Email to document
    ${mail_data} =     Get File    devdata${/}mail.eml
    HTML to PDF    ${mail_data}    output${/}mail.pdf


PDF to XML parse
    ${xml} =     Dump PDF as XML    ${boost_invoice}
    Log    ${xml}
    Should Not Be Empty    ${xml}
    ${elem} =    Parse Xml    ${xml}    strip_namespaces=True
    Log    ${elem}
