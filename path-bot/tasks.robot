*** Settings ***
Documentation       Template robot main suite.


*** Tasks ***
Show Python Version
    ${ver} =    Evaluate    sys.version    modules=sys
    Log To Console    Python version: ${ver}
