*** Settings ***

Resource       cumulusci/robotframework/Salesforce.robot
Library        robot/OutboundFundsNPSP/resources/OutboundFundsNPSP.py
Library        DateTime

*** Keywords ***

Capture Screenshot and Delete Records and Close Browser
    [Documentation]                 This keyword will capture a screenshot before closing
    ...                             the browser and deleting records when test fails
    Run Keyword If Any Tests Failed      Capture Page Screenshot
    Close Browser
    Delete Session Records

API Create Account
    [Documentation]                 Create an Account for user
    [Arguments]                     &{fields}
    ${name} =                       Generate New String
    ${account_id} =                 Salesforce Insert  Account
    ...                             Name=${name}
    ...                             &{fields}
    &{account} =                    Salesforce Get  Account  ${account_id}
    [return]                        &{account}

API Create Contact
    [Documentation]                 Create a contact via API
    [Arguments]                     &{fields}
    ${contact_id} =                 Salesforce Insert  Contact
    ...                             FirstName=${faker.first_name()}
    ...                             LastName=${faker.last_name()}
    ...                             &{fields}
    &{contact} =                    Salesforce Get  Contact  ${contact_id}
    [Return]                        &{contact}

API Create Contact for User
    [Documentation]                 Create a contact via API for user creation
    [Arguments]                     ${account_id}   &{fields}
    ${email}=                       Random Email
    ${contact_id} =                 Salesforce Insert  Contact
    ...                             FirstName=${faker.first_name()}
    ...                             LastName=${faker.last_name()}
    ...                             AccountId=${account_id}
    ...                             Email=${email}
    ...                             &{fields}
    &{contact} =                    Salesforce Get  Contact  ${contact_id}
    [Return]                        &{contact}

API Create Funding Program
    [Documentation]                 Create a Funding Program via API
    [Arguments]                     &{fields}
    ${funding_program_name} =       Generate New String
    ${start_date} =                 Get Current Date  result_format=%Y-%m-%d
    ${end_date} =                   Get Current Date  result_format=%Y-%m-%d    increment=90 days
    ${funding_program_id} =         Salesforce Insert  outfunds__Funding_Program__c
    ...                             Name=${funding_program_name}
    ...                             outfunds__Start_Date__c=${start_date}
    ...                             outfunds__End_Date__c=${end_date}
    ...                             outfunds__Status__c=In Progress
    ...                             outfunds__Total_Program_Amount__c=100000
    ...                             outfunds__Description__c=Robot API Program
    ...                             &{fields}
    &{fundingprogram} =             Salesforce Get  outfunds__Funding_Program__c  ${funding_program_id}
    [Return]                        &{fundingprogram}

API Create Funding Request
    [Documentation]                 Create a Funding Request via API
    [Arguments]                     ${funding_program_id}  ${contact_id}    &{fields}
    ${funding_request_name} =       Generate New String
    ${application_date} =           Get Current Date  result_format=%Y-%m-%d
    ${funding_request_id} =         Salesforce Insert  outfunds__Funding_Request__c
    ...                             Name=${funding_request_name}
    ...                             outfunds__Applying_Contact__c=${contact_id}
    ...                             outfunds__Status__c=In Progress
    ...                             outfunds__Requested_Amount__c=100000
    ...                             outfunds__FundingProgram__c=${funding_program_id}
    ...                             outfunds__Requested_For__c=Education
    ...                             &{fields}
    &{funding_request} =            Salesforce Get  outfunds__Funding_Request__c  ${funding_request_id}
    Store Session Record            outfunds__Funding_Request__c   ${funding_request_id}
    [Return]                        &{funding_request}

API Create Requirement on a Funding Request
    [Documentation]                 Create a Requirement on a Funding Request via API
    [Arguments]                     ${funding_request_id}  ${contact_id}    ${user_id}   &{fields}
    ${requirement_name} =           Generate New String
    ${due_date} =                   Get Current Date  result_format=%Y-%m-%d    increment=30 days
    ${requirement_id} =             Salesforce Insert  outfunds__Requirement__c
    ...                             Name=${requirement_name}
    ...                             outfunds__Primary_Contact__c=${contact_id}
    ...                             outfunds__Due_Date__c=${due_date}
    ...                             outfunds__Assigned__c=${user_id}
    ...                             outfunds__Status__c=Open
    ...                             outfunds__Funding_Request__c=${funding_request_id}
    ...                             outfunds__Type__c=Review
    ...                             &{fields}
    &{requirement} =                Salesforce Get  outfunds__Requirement__c  ${requirement_id}
    Store Session Record            outfunds__Requirement__c   ${requirement_id}
    [Return]                        &{requirement}

API Create Disbursement on a Funding Request
    [Documentation]                 Create a Disbursement on a Funding Request via API
    [Arguments]                     ${funding_request_id}  &{fields}
    ${scheduled_date} =             Get Current Date  result_format=%Y-%m-%d    increment=5 days
    ${disbursement_date} =          Get Current Date  result_format=%Y-%m-%d    increment=10 days
    ${disbursement_id} =            Salesforce Insert  outfunds__Disbursement__c
    ...                             outfunds__Funding_Request__c=${funding_request_id}
    ...                             outfunds__Amount__c=5000
    ...                             outfunds__Status__c=Scheduled
    ...                             outfunds__Scheduled_Date__c=${scheduled_date}
    ...                             outfunds__Type__c=Initial
    ...                             outfunds__Disbursement_Date__c=${disbursement_date}
    ...                             outfunds__Disbursement_Method__c=Check
    ...                             &{fields}
    &{disbursement} =               Salesforce Get  outfunds__Disbursement__c  ${disbursement_id}
    Store Session Record            outfunds__disbursement__c   ${disbursement_id}
    [Return]                        &{disbursement}


API Create GAU
    [Documentation]                Create a GAU
    [Arguments]                    &{fields}
    ${name} =                      Generate New String
    ${gau_id} =                    Salesforce Insert  npsp__General_Accounting_Unit__c
    ...                            npsp__Active__c=true
    ...                            npsp__Total_Allocations__c=50000
    ...                            npsp__Description__c=Robot Test
    ...                            Name=${name}
    &{gau} =                       Salesforce Get  npsp__General_Accounting_Unit__c  ${gau_id}
    Store Session Record           npsp__General_Accounting_Unit__c   ${gau_id}
    [Return]                       &{gau}

API Create GAU Expenditure
    [Documentation]                Create a GAU Expenditure on Disbursement
    [Arguments]                    ${gau_id}    ${disbursement_id}   &{fields}
    ${gauexpenditure_id} =         Salesforce Insert  GAU_Expenditure__c
    ...                            Amount__c=10000
    ...                            General_Accounting_Unit__c=${gau_id}
    ...                            Disbursement__c=${disbursement_id}
    &{gauexp} =                    Salesforce Get  GAU_Expenditure__c  ${gauexpenditure_id}
    Store Session Record           GAU_Expenditure__c   ${gauexpenditure_id}
    [Return]                       &{gauexp}

