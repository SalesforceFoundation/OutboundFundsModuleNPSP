*** Settings ***
Documentation  User with Read Only Access should not  be able to Create a Disbursement
Resource       robot/OutboundFundsNPSP/resources/OutboundFundsNPSP.robot
Library        cumulusci.robotframework.PageObjects
...            robot/OutboundFundsNPSP/resources/FundingRequestPageObject.py


Suite Setup     Run keywords
...             Open test browser       useralias=${test_user}      AND
...             Setup Test Data
Suite Teardown  Capture Screenshot And Delete Records And Close Browser

*** Variables ***
${test_user}             permtest

*** Keywords ***
Setup Test Data
    [Documentation]                   Create data to run tests
    ${ns} =                             Get Outfundsnpsp Namespace Prefix
    Set suite variable                  ${ns}
    ${ns_npsp} =                        Get NPSP Namespace Prefix
    Set suite variable                  ${ns_npsp}
    ${fundingprogram} =                 API Create Funding Program
    Store Session Record                ${ns}Funding_Program__c         ${fundingprogram}[Id]
    Set suite variable                  ${fundingprogram}
    ${contact} =                        API Create Contact
    Store Session Record                Contact                              ${contact}[Id]
    Set suite variable                  ${contact}
    ${funding_request} =                API Create Funding Request           ${fundingprogram}[Id]
    ...                                 ${contact}[Id]
    Store Session Record                ${ns}Funding_Request__c         ${funding_request}[Id]
    Set suite variable                  ${funding_request}
    &{gau}=                             API Create GAU
    Set Suite Variable                  &{gau}
    ${date_1} =                         Get current date    result_format=%m/%d/%Y  increment=1 day
    ${date_2} =                         Get current date    result_format=%m/%d/%Y  increment=10 day
    Set suite variable                  ${date_1}
    Set suite variable                  ${date_2}

*** Test Case ***
Disbursement FLS Check
    [Documentation]                             Login as User who only have read access
    ...                                         to Disbursements Object and Verify
    ...                                         that user cannot save a disbursement
    [tags]                                      feature:GAU
    Go To Page                                  Details     Funding_Request__c
    ...                                         object_id=${funding_request}[Id]
    Wait Until Loading Is Complete
    Click Tab                                   Disbursements
    click related list wrapper button           Disbursements                               New
    Wait For Modal                              New                                  Disbursements
    Populate Field                              Amount          10000
    Select Value from Picklist                  Status          Scheduled
    Select Value from Picklist                  Type            Initial
    Select Value from Picklist                  Disbursement Method         Check
    Add Date                                    Scheduled Date              ${date_1}
    Add Date                                    Disbursement Date           ${date_2}
    Click Save
    Click Related List Link With Text           D-
    Click Tab                                   GAU Expenditures
    Wait Until Element Is Not Visible           New
    Click Button                                Add Row
    Populate Field With Id                      input           10000
    Verify Button Status                        Save Updates=disabled
