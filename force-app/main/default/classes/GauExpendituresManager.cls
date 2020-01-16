public with sharing class GauExpendituresManager {
  @AuraEnabled(cacheable=true)
  public static DisbursementWrapper getDisbursement(String disbursementId) {
    List<outfunds__Disbursement__c> disbursements = [
      SELECT
        Id,
        Name,
        outfunds__Amount__c,
        (
          SELECT
            Id,
            General_Accounting_Unit__c,
            General_Accounting_Unit__r.Name,
            Amount__c
          FROM GAU_Expendatures__r
          LIMIT 200
        )
      FROM outfunds__Disbursement__c
      WHERE Id = :disbursementId
      LIMIT 1
    ];
    outfunds__Disbursement__c disbursement = disbursements.size() == 1
      ? disbursements.get(0)
      : null;

    return new DisbursementWrapper(disbursement);
  }
}
