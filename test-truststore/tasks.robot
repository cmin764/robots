*** Settings ***
Library     OperatingSystem
Library     RPA.Robocorp.Vault


*** Tasks ***
Vault Test
    # &{env_vars} =    Evaluate    os.environ     modules=os
    # Log To Console    ${env_vars}

    ${secret_name} =    Get Environment Variable  SECRET_NAME  default=test_truststore
    ${secrets}    Get Secret    ${secret_name}
    Log to console    ${secrets}[test]
