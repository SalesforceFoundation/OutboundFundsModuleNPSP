public with sharing class GauExpenditureSelector {
    public List<outfunds__Disbursement__c> getDisbursementsById(String disbursementId) {
        return [
            SELECT
                Id,
                Name,
                outfunds__Amount__c,
                outfunds__Status__c,
                (
                    SELECT
                        Id,
                        General_Accounting_Unit__c,
                        General_Accounting_Unit__r.Name,
                        General_Accounting_Unit__r.npsp__Active__c,
                        Amount__c
                    FROM GAU_Expendatures__r
                    ORDER BY CreatedDate ASC
                    LIMIT 200
                )
            FROM outfunds__Disbursement__c
            WHERE Id = :disbursementId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
}
