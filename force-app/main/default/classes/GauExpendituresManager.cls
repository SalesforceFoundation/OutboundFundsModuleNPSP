/*******************************************************************************
 * @author Thom Behrens
 * @date 2020-01-25
 *
 * @description Class made in support of the manageExpenditures lwc. selector and update method made so that as much
 * logic as possible can be handle on this end, and as such, some assumptions about what is being passed from the UI
 * are made. E.g. when a list of GAU Expenditures is recieved along with a disbursement Id, we assume that any expenditures
 * not in that list should be deleted, since they've been deleted in the UI.
 */
public with sharing class GauExpendituresManager {
  /*****************************************************************************
   * @description using a disbursementId (Passed from a lightning record page), return a wrapper for the disbursement object.
   * One of the properties of this wrapper is a list of wrappers for the GAU Expenditure object, with the disbursements children.
   * @param String disbursementId
   * @return DisbursementWrapper
   * @example
   * GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
   *   String.valueOf(disbursement.Id)
   * );
   */
  @AuraEnabled
  public static DisbursementWrapper getDisbursement(String disbursementId) {
    List<outfunds__Disbursement__c> disbursements = [
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
  /*****************************************************************************
   * @description Recieve stringified version of the gau expenditures, with the id of the parent. Upsert and delete children as needed.
   * @param String expenditureString
   * @param String disbursementId
   * @return void
   * @example
   * GauExpendituresManager.upsertGauExpenditures(
   *   expendituresString,
   *   disbursement.Id
   * );
   */
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
      delete expendituresToDelete;
      upsert expenditures;
    } catch (Exception e) {
      Database.rollback(sp);
      if (Test.isRunningTest()) {
        throw new ConstructedException(e.getMessage());
      } else {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }
  /*****************************************************************************
   * @description deduce which expenditures should be deleted by querying all expenditures, and checking to see which
   * ones are not in the list of those to be preserved.
   * @param List<GAU_Expenditure__c> remainingExpenditures
   * @param String disbursementId
   * @return List<GAU_Expenditure__c> - records to be deleted
   * @example
   * List<Gau_Expenditure__c> expendituresToDelete = queryDeletedExpenditures(
   *   expenditures,
   *   disbursementId
   * );
   */
  private static List<GAU_Expenditure__c> queryDeletedExpenditures(
    List<GAU_Expenditure__c> remainingExpenditures,
    String disbursementId
  ) {
    Set<Id> remainingExpenditureIds = new Set<Id>();
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

  /*******************************************************************************
   * @author Thom Behrens
   * @date 2020-01-25
   *
   * @description Wrapper class for the outfunds__Disbursement__c object
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
      for (
        GAU_Expenditure__c gauExpenditure : disbursement.GAU_Expendatures__r
      ) {
        this.expenditures.add(
          new GauExpenditureWrapper(gauExpenditure, rowId++)
        );
      }
    }
  }
  /*******************************************************************************
   * @author Thom Behrens
   * @date 2020-01-25
   *
   * @description Wrapper class for the GAU_Expenditure__c object.
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
      this.gauIsActive = gauExpenditure.General_Accounting_Unit__r.npsp__Active__c;
      this.rowId = rowId;
    }
  }

  public class ConstructedException extends Exception {
  }
}
