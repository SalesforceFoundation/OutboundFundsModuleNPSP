public with sharing class GauExpenditureSelector {
    public List<Schema.outfunds__Disbursement__c> getDisbursementsById(
        String disbursementId
    ) {
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

    /**
     * Deduce which expenditures should be deleted by querying all expenditures, and checking to see which ones are not in the list of those to be preserved.
     * @return   return description
     */
    public List<Schema.GAU_Expenditure__c> getExpendituresToDelete(
        String disbursementId,
        Set<Id> expenditureIdsToKeep
    ) {
        final Set<Id> normalizedExpenditureIdsToKeep = new Set<Id>();
        if (expenditureIdsToKeep != null) {
            normalizedExpenditureIdsToKeep.addAll(expenditureIdsToKeep);
        }

        final List<Schema.GAU_Expenditure__c> expendituresToDelete = new List<Schema.GAU_Expenditure__c>();
        for (Schema.GAU_Expenditure__c expenditure : [
            SELECT Id
            FROM GAU_Expenditure__c
            WHERE Disbursement__c = :disbursementId
            WITH SECURITY_ENFORCED
        ]) {
            if (!normalizedExpenditureIdsToKeep.contains(expenditure.Id)) {
                expendituresToDelete.add(expenditure);
            }
        }
        return expendituresToDelete;
    }

    public List<Schema.npsp__General_Accounting_Unit__c> getActiveGeneralAccountUnitsLikeName(
        String nameLikeClause
    ) {
        final String name = String.isBlank(nameLikeClause)
            ? '%'
            : String.escapeSingleQuotes(nameLikeClause) + '%';
        return [
            SELECT Id, Name, npsp__Description__c
            FROM npsp__General_Accounting_Unit__c
            WHERE Name LIKE :name AND npsp__Active__c = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 5
        ];
    }
}
