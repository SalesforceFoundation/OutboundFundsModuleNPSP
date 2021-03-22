*** Settings ***
Documentation  Create Funding Request, Add Disbursement on an Awarded Funding Request
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
    ${fundingprogram} =                 API Create Funding Program
    Store Session Record                ${ns}Funding_Program__c         ${fundingprogram}[Id]
    Set suite variable                  ${fundingprogram}
    ${contact} =                        API Create Contact
    Store Session Record                Contact                   ${contact}[Id]
    Set suite variable                  ${contact}
    ${funding_request} =                API Create Funding Request
    ...                                 ${fundingprogram}[Id]     ${contact}[Id]
    Store Session Record                ${ns}Funding_Request__c             ${funding_request}[Id]
    Set suite variable                  ${funding_request}
    ${awardedfunding_request} =         API Create Funding Request
    ...                                 ${fundingprogram}[Id]     ${contact}[Id]
    ...                                 ${ns}Status__c=Awarded  ${ns}Awarded_Amount__c=100000
    Store Session Record                ${ns}Funding_Request__c     ${awardedfunding_request}[Id]
    Set suite variable                  ${awardedfunding_request}
    ${fr_name} =                        Generate New String
    Set suite variable                  ${fr_name}
    ${req_name} =                       Generate New String
    Set suite variable                  ${req_name}
    ${date_1} =                         Get current date    result_format=%m/%d/%Y  increment=1 day
    ${date_2} =                         Get current date    result_format=%m/%d/%Y   increment=10 day
    Set suite variable                  ${date_1}
    Set suite variable                  ${date_2}



*** Test Case ***
Create Funding Request Via API
    [Documentation]                             Creates a Funding Request via API.
    ...                                         Verifies that Funding Request is created and
    ...                                         displays under recently viewed Funding Request
    [tags]                                      W-8865884        feature:FundingRequest
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${funding_request}[Name]
    Wait Until Loading Is Complete
    Current Page Should Be                      Details          Funding_Request__c
    Validate Field Value                        Status  contains    In progress
    Validate Field Value                        Funding Request Name    contains
    ...                                         ${funding_request}[Name]

Create Funding Request via UI
     [Documentation]                            Creates a Funding Request via UI.
     ...                                        Verifies that Funding Request is created.
     [tags]                                     W-8865897       feature:FundingRequest
     Go To Page                                 Listing          ${ns}Funding_Request__c
     Click Object Button                        New
     wait until modal is open
     Populate Field                             Funding Request Name    ${fr_name}
     Populate Lookup Field                      Funding Program     ${fundingprogram}[Name]
     Populate Lookup Field                      Applying Contact    ${contact}[Name]
     Add Date                                   Application Date      ${date_1}
     Select Value from Picklist                 Status          Submitted
     Select Value from Picklist                 Geographical Area Served        Region
     Populate Field                             Requested Amount        10000
     Populate Field                             Requested For           Robot Testing
     Click Save
     wait until modal is closed
     Current Page Should Be                     Details           Funding_Request__c
     Validate Field Value                       Funding Request Name    contains    ${fr_name}

Add a Disbursement on an awarded Funding Request
    [Documentation]                             Creates a Funding Request via API.
    ...                                         Go to Disbursements and add a new Disbursement
    [tags]                                      feature:FundingRequest    Disbursements
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${awardedfunding_request}[Name]
    Wait Until Loading Is Complete
    Current Page Should Be                      Details          Funding_Request__c
    Click button                                Create Disbursements
    wait until modal is open
    Populate Field                              Number of Disbursements     4
    Populate Field                              Interval    4
    Populate Field                              Amount      80000
    click button                                Calculate
    Wait Until Element Is Visible               text:Scheduled Date
    Save Disbursement
    Current Page Should Be                      Details          Funding_Request__c
    Validate Field Value                        Unpaid Disbursements    contains    $80,000.00
    Validate Field Value                        Available for Disbursement   contains   $20,000.00
    Validate Field Value                        Unpaid Disbursements          contains         $80,000.00
    Validate Field Value                        Available for Disbursement          contains         $20,000.00

Create a Disbursement on an Awarded Funding Request via Related List
    [Documentation]                             Creates a Funding Request via API.
    ...                                         Go to Disbursements and add a new Disbursement
    [tags]                                      feature:Funding Request    Disbursements
    Go To Page                                  Listing          ${ns}Funding_Request__c
    Click Link With Text                        ${awardedfunding_request}[Name]
    Wait Until Loading Is Complete
    Current Page Should Be                      Details          Funding_Request__c
    Click Tab                                   Disbursements
    click related list wrapper button           Disbursements           New
    Wait For Modal                              New                     Disbursement
    Populate Field                              Amount          10000
    Select Value from Picklist                  Status          Scheduled
    Select Value from Picklist                  Type            Initial
    Select Value from Picklist                  Disbursement Method         Check
    Add Date                                    Scheduled Date              ${date_1}
    Add Date                                    Disbursement Date           ${date_2}
    Click Save

