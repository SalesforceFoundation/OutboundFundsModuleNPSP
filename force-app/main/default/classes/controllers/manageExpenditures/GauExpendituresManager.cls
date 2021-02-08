/**
 * Class made in support of the manageExpenditures lwc. selector and update method made so that as much
 * logic as possible can be handle on this end, and as such, some assumptions about what is being passed from the UI
 * are made. E.g. when a list of GAU Expenditures is received along with a disbursement Id, we assume that any expenditures
 * not in that list should be deleted, since they've been deleted in the UI.
 */
public with sharing class GauExpendituresManager {
    @TestVisible
    private static GanExpenditureSelector gauExpenditureSelector = new GanExpenditureSelector();

    @TestVisible
    private static DatabaseService databaseService = new DatabaseService();

    /**
     * Using a disbursementId (Passed from a lightning record page), return a wrapper for the disbursement object.
     * One of the properties of this wrapper is a list of wrappers for the GAU Expenditure object, with the disbursements children.
     * @param  disbursementId disbursementId description
     * @return                DisbursementWrapper of a outfunds__Disbursement__c.
     */
    @AuraEnabled
    public static DisbursementWrapper getDisbursement(String disbursementId) {
        try {
            final List<outfunds__Disbursement__c> disbursements = GauExpendituresManager.gauExpenditureSelector.getDisbursementsById(
                disbursementId
            );

            if (disbursements.isEmpty()) {
                return null;
            }
            return new DisbursementWrapper(disbursements[0]);
        } catch (Exception e) {
            // Re-throw as an AuraHandledException that Lightning Components can handle.
            final System.AuraHandledException auraHandledException = new System.AuraHandledException(
                e.getMessage()
            );
            auraHandledException.setMessage(e.getMessage());
            throw auraHandledException;
        }
    }

    /*****************************************************************************
     * @description
     * @param String expenditureString
     * @param String disbursementId
     * @return void
     * @example
     * GauExpendituresManager.upsertGauExpenditures(
     *   expendituresString,
     *   disbursement.Id
     * );
     */
    /**
     * Receives a JSON serialized version of the GAU Expenditures, with the id of the parent. Upsert and delete children as needed.
     */
    @AuraEnabled
    public static void upsertGauExpenditures(
        String expendituresString,
        String disbursementId
    ) {
        final DatabaseService.Savepoint savepoint = GauExpendituresManager.databaseService.setSavepoint();

        try {
            // Deserialize expendituresString and split into records to insert and update.
            final List<Schema.GAU_Expenditure__c> expendituresToInsert = new List<Schema.GAU_Expenditure__c>();
            final Map<Id, Schema.GAU_Expenditure__c> expendituresToUpdate = new Map<Id, Schema.GAU_Expenditure__c>();

            for (
                GauExpendituresManager.GauExpenditureWrapper expenditureWrapper : (List<GauExpendituresManager.GauExpenditureWrapper>) JSON.deserialize(
                    expendituresString,
                    List<GauExpendituresManager.GauExpenditureWrapper>.class
                )
            ) {
                final Schema.GAU_Expenditure__c expenditure = new Schema.GAU_Expenditure__c(
                    Id = expenditureWrapper.recordId,
                    Disbursement__c = disbursementId,
                    General_Accounting_Unit__c = expenditureWrapper.gauId,
                    Amount__c = expenditureWrapper.amount
                );

                if (expenditure.Id == null) {
                    expendituresToInsert.add(expenditure);
                } else {
                    expendituresToUpdate.put(expenditure.Id, expenditure);
                }
            }

            // Delete child records not contained in expendituresString.
            GauExpendituresManager.databaseService.deleteRecords(
                GauExpendituresManager.gauExpenditureSelector.getExpendituresToDelete(
                    disbursementId
                )
            );

            // Upsert records in expendituresString.
            GauExpendituresManager.databaseService.insertRecordsEnforceFls(
                expendituresToInsert
            );
            GauExpendituresManager.databaseService.updateRecordsEnforceFls(
                expendituresToUpdate
            );
        } catch (Exception e) {
            // Rollback transaction.
            GauExpendituresManager.databaseService.rollback(savepoint);

            // Re-throw as an AuraHandledException that Lightning Components can handle.
            final System.AuraHandledException auraHandledException = new System.AuraHandledException(
                e.getMessage()
            );
            auraHandledException.setMessage(e.getMessage());
            throw auraHandledException;
        }
    }

    /**
     * Wrapper class for the outfunds__Disbursement__c object
     */
    public class DisbursementWrapper {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public List<GauExpenditureWrapper> expenditures;
        public DisbursementWrapper(outfunds__Disbursement__c disbursement) {
            this.recordId = disbursement.Id;
            this.name = disbursement.Name;
            this.amount = disbursement.outfunds__Amount__c;
            this.status = disbursement.outfunds__Status__c;
            this.expenditures = new List<GauExpenditureWrapper>();
            Integer rowId = 1;
            for (GAU_Expenditure__c gauExpenditure : disbursement.GAU_Expendatures__r) {
                this.expenditures.add(new GauExpenditureWrapper(gauExpenditure, rowId++));
            }
        }
    }

    /**
     * Wrapper class for the GAU_Expenditure__c object.
     */
    public class GauExpenditureWrapper {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public Id gauId;
        @AuraEnabled
        public String gauName;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Boolean gauIsActive;
        @AuraEnabled
        public Integer rowId;
        public GauExpenditureWrapper(GAU_Expenditure__c gauExpenditure, Integer rowId) {
            this.recordId = gauExpenditure.Id;
            this.gauId = gauExpenditure.General_Accounting_Unit__c;
            if (this.gauId != null) {
                this.gauName = gauExpenditure.General_Accounting_Unit__r.Name;
            }
            this.amount = gauExpenditure.Amount__c;
            this.gauIsActive = gauExpenditure.General_Accounting_Unit__r.npsp__Active__c;
            this.rowId = rowId;
        }
    }
}
