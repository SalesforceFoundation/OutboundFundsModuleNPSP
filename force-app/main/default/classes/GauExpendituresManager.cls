public with sharing class GauExpendituresManager {
  @AuraEnabled
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

  @AuraEnabled
  public static void upsertGauExpenditures(
    String expendituresString,
    String disbursementId
  ) {
    List<GauExpenditureWrapper> expenditureWrappers = (List<GauExpenditureWrapper>) JSON.deserialize(
      expendituresString,
      List<GauExpenditureWrapper>.class
    );
    List<GAU_Expenditure__c> expenditures = new List<GAU_Expenditure__c>();
    for (GauExpenditureWrapper expenditureWrapper : expenditureWrappers) {
      expenditures.add(
        new GAU_Expenditure__c(
          Id = expenditureWrapper.recordId,
          Disbursement__c = disbursementId,
          General_Accounting_Unit__c = expenditureWrapper.gauId,
          Amount__c = expenditureWrapper.amount
        )
      );
    }
    List<Gau_Expenditure__c> expendituresToDelete = queryDeletedExpenditures(
      expenditures,
      disbursementId
    );
    Savepoint sp = Database.setSavepoint();
    try {
      upsert expenditures;
      delete expendituresToDelete;
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static List<GAU_Expenditure__c> queryDeletedExpenditures(
    List<GAU_Expenditure__c> remainingExpenditures,
    String disbursementId
  ) {
    List<Id> remainingExpenditureIds = new List<Id>();
    for (GAU_Expenditure__c expenditure : remainingExpenditures) {
      remainingExpenditureIds.add(expenditure.Id);
    }
    List<GAU_Expenditure__c> allExpenditures = [
      SELECT Id
      FROM GAU_Expenditure__c
      WHERE Disbursement__c = :disbursementId
    ];
    List<GAU_Expenditure__c> expendituresToDelete = new List<GAU_Expenditure__c>();
    for (GAU_Expenditure__c expenditure : allExpenditures) {
      if (!remainingExpenditureIds.contains(expenditure.Id)) {
        expendituresToDelete.add(expenditure);
      }
    }
    return expendituresToDelete;
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
      Integer rowId = 1;
      for (
        GAU_Expenditure__c gauExpenditure : disbursement.GAU_Expendatures__r
      ) {
        this.expenditures.add(
          new GauExpenditureWrapper(gauExpenditure, rowId++)
        );
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
    public GauExpenditureWrapper(
      GAU_Expenditure__c gauExpenditure,
      Integer rowId
    ) {
      this.recordId = gauExpenditure.Id;
      this.gauId = gauExpenditure.General_Accounting_Unit__c;
      if (this.gauId != null) {
        this.gauName = gauExpenditure.General_Accounting_Unit__r.Name;
      }
      this.amount = gauExpenditure.Amount__c;
      this.rowId = rowId;
    }
  }
}
