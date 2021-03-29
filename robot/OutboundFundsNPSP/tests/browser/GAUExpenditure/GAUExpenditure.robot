*** Settings ***
Documentation  Create GAU Expenditure
Resource       robot/OutboundFundsNPSP/resources/OutboundFundsNPSP.robot
Library        cumulusci.robotframework.PageObjects
...            robot/OutboundFundsNPSP/resources/FundingRequestPageObject.py

Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture Screenshot And Delete Records And Close Browser

*** Keywords ***
Setup Test Data
    [Documentation]                   Create data to run tests
    ${ns} =                             Get Outfundsnpsp Namespace Prefix
    Set suite variable                  ${ns}
    ${ns_npsp} =                        Get NPSP Namespace Prefix
    Set suite variable                  ${ns_npsp}
    ${ns_npspext} =                     Get Outfundsnpspext Namespace Prefix
    Set suite variable                  ${ns_npspext}
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
    ${disbursed_request} =              API Create Funding Request           ${fundingprogram}[Id]
    ...                                 ${contact}[Id]
    ...                                 ${ns}Awarded_Amount__c=100000
    ...                                 ${ns}Status__c=Fully Disbursed
    Store Session Record                ${ns}Funding_Request__c         ${disbursed_request}[Id]
    Set suite variable                  ${disbursed_request}
    ${disbursement}                     API Create Disbursement on a Funding Request
    ...                                 ${funding_request}[Id]
    Set Suite Variable                  ${disbursement}
    &{gau}=                             API Create GAU
    Set Suite Variable                  &{gau}
    &{gau_exp}=                         API Create GAU Expenditure          ${gau}[Id]
    ...                                 ${disbursement}[Id]
    Set Suite Variable                  &{gau_exp}
    ${fully_disbursed}                  API Create Disbursement on a Funding Request
    ...                                 ${disbursed_request}[Id]
    ...                                 ${ns}Status__c=Paid
    Set Suite Variable                  ${fully_disbursed}
    &{gau_paid}=                        API Create GAU Expenditure          ${gau}[Id]
     ...                                ${fully_disbursed}[Id]
     Set Suite Variable                 ${gau_paid}

*** Test Case ***
Verify GAU Expenditure created is added on Disbursement
    [Documentation]                   Create GAU Expenditure via API and
    ...                               verify record is added on Disbursement Record
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${funding_request}[Name]
    Click Tab                                   Disbursements
    Click Related List Link with Text           ${disbursement}[Name]
    Click Tab                                   GAU Expenditures
    Click Related List Link with Text           ${gau_exp}[Name]
    Validate Field Value                        General Accounting Unit    contains    ${gau}[Name]
    Validate Field Value                        Amount    contains    $10,000.00

Verify GAU Expenditure on Paid Disbursement
    [Documentation]                   Create a Disbursement and set status to Paid
    ...                               Verify Manage Expenditure is disabled
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${disbursed_request}[Name]
    Click Tab                                   Disbursements
    Click Related List Link with Text           ${fully_disbursed}[Name]
    Click Tab                                   GAU Expenditures
    Verify Button Status                        Save Updates=disabled
