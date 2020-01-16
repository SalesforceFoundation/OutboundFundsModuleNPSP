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
    DisbursementWrapper generatedDisbursementWrapper = new DisbursementWrapper(
      disbursement
    );
    console.log(generatedDisbursementWrapper);
    return generatedDisbursementWrapper;
  }

  public class DisbursementWrapper {
    public Id recordId;
    public String name;
    public Decimal amount;
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
    public Id recordId;
    public Id gauId;
    public String gauName;
    public Decimal amount;

    public GauExpenditureWrapper(GAU_Expenditure__c gaue) {
      this.recordId = gaue.Id;
      this.gauId = gaue.General_Accounting_Unit__c;
      if (gaue.General_Accounting_Unit__c != null) {
        this.gauName = gaue.General_Accounting_Unit__r.Name;
      }
      this.amount = gaue.Amount__c;
    }
  }
}
