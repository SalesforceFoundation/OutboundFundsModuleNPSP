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

    if (disbursement == null) {
      return null;
    }

    return new DisbursementWrapper(disbursement);
  }

  public class DisbursementWrapper {
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Decimal amount;
    @AuraEnabled
    public List<GauExpenditureWrapper> expenditures;
    public DisbursementWrapper(outfunds__Disbursement__c disbursement) {
      this.recordId = disbursement.Id;
      this.name = disbursement.Name;
      this.amount = disbursement.outfunds__Amount__c;
      this.expenditures = new List<GauExpenditureWrapper>();
      for (
        GAU_Expenditure__c gauExpenditure : disbursement.GAU_Expendatures__r
      ) {
        this.expenditures.add(new GauExpenditureWrapper(gauExpenditure));
      }
    }
  }

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
    public Integer rowId;
    public GauExpenditureWrapper(GAU_Expenditure__c gauExpenditure) {
      this.recordId = gauExpenditure.Id;
      this.gauId = gauExpenditure.General_Accounting_Unit__c;
      if (this.gauId != null) {
        this.gauName = gauExpenditure.General_Accounting_Unit__r.Name;
      }
      this.amount = gauExpenditure.Amount__c;
    }
  }
}
