*** Settings ***

Resource       robot/OutboundFundsNPSP/resources/OutboundfundsNPSP.robot
Library        cumulusci.robotframework.PageObjects
...            robot/OutboundFundsNPSP/resources/FundingProgramPageObject.py
...            robot/OutboundFundsNPSP/resources/OutboundFundsNPSP.py

Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture Screenshot And Delete Records And Close Browser

*** Keywords ***
Setup Test Data
    ${ns} =                           Get Outfundsnpsp Namespace Prefix
    Set suite variable                ${ns}
    &{fundingprogram} =               API Create Funding Program
    ${fp_name} =                      Generate New String
    Set suite variable                &{fundingprogram}
    Set suite variable                ${fp_name}
*** Test Case ***
Create Funding Program Via API
    [Documentation]                             Creates a Funding Program via API.
    ...                                         Verifies that Funding Program is created and
    ...                                         displays under recently viewed Funding Program
    [tags]                                      W-8865873        feature:FundingProgram
    Go To Page                                  Listing          ${ns}Funding_Program__c
    Click Link With Text                        ${fundingprogram}[Name]
    Wait Until Loading Is Complete
    Current Page Should Be                      Details          Funding_Program__c

Create Funding Program via UI
    [Documentation]                             Creates a Funding Program via UI.
     ...                                        Verifies that Funding Program is created.
     [tags]                                     W-8865863       feature:FundingProgram
     Go To Page                                 Listing          ${ns}Funding_Program__c
     Click Object Button                        New
     Wait Until Modal Is Open
     Populate Field                             Funding Program Name        ${fp_name}
     Populate Field                             Description         Automated Robot Funding Program
     Click Save
     Wait Until Modal Is Closed
     Current Page Should Be                     Details          Funding_Program__c