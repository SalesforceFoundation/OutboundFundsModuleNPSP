*** Settings ***
Documentation  Create Requirement on a Funding Request
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
    ${ns} =                           Get Outfundsnpsp Namespace Prefix
    Set Suite Variable                ${ns}
    ${fundingprogram} =               API Create Funding Program
    Set suite variable                ${fundingprogram}
    ${contact} =                      API Create Contact
    Store Session Record              Contact                              ${contact}[Id]
    Set suite variable                ${contact}
    ${funding_request} =              API Create Funding Request
    ...                               ${fundingprogram}[Id]     ${contact}[Id]
    ...                               ${ns}Status__c=In Progress
    ...                               ${ns}Awarded_Amount__c=100000
    Store Session Record              ${ns}Funding_Request__c         ${funding_request}[Id]
    Set suite variable                ${funding_request}
    ${req_name} =                     Generate New String
    Set suite variable                ${req_name}

*** Test Case ***
Add a Requirement on a Funding Request
    [Documentation]                             Creates a Funding Request via API.
    ...                                         Go to Requirements and add a new Requirement
    [tags]                                      feature:Requirements
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${funding_request}[Name]
    Wait Until Loading Is Complete
    Current Page Should Be                      Details          Funding_Request__c
    Click Tab                                   Requirements
    click related list wrapper button           Requirements            New
    Wait For Modal                              New                     Requirement
    Populate Field                              Requirement Name        ${req_name}
    Populate Lookup Field                       Primary Contact     ${contact}[Name]
    Click Save
    wait until modal is closed
    Click Related List Link With Text           ${req_name}
    Select Tab                                  Details
    Validate Field Value                        Requirement Name    contains    ${req_name}
    Validate Field Value                        Primary Contact    contains    ${contact}[Name]
