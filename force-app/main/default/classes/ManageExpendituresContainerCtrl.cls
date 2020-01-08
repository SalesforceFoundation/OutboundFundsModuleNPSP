public with sharing class ManageExpendituresContainerCtrl {
  /** @description The Id of the parent Disbursement */
  public Id parentId { get; set; }

  /** @description The Name of the parent Disbursement */
  public String parentName { get; set; }

  /** @description List of expenditures, represented in JSON */
  public String gauExpenditureWrappers { get; set; }

  /*****************************************************************************
   * @description Constructor queries for the parent object id - all inner logic
   * handled by the lwc.
   */
  public ManageExpendituresContainerCtrl(ApexPages.StandardSetController ssc) {
    parentId = ApexPages.currentPage().getParameters().get('id');

    List<outfunds__Disbursement__c> disbursements = [
      SELECT
        Id,
        Name,
        (
          SELECT Id, General_Accounting_Unit__c, General_Accounting_Unit__r.Name, Amount__c, Disbursement__c
          FROM GAU_Expendatures__r
          LIMIT 500
        )
      FROM outfunds__Disbursement__c
      WHERE Id = :parentId
      LIMIT 1
    ];
    outfunds__Disbursement__c disbursement = disbursements.size() == 1
      ? disbursements.get(0)
      : null;

    // TODO: error check for null case

    parentName = disbursement.Name;

    List<GauExpenditureWrapper> gauExpenditureWrapperlist = new List<GauExpenditureWrapper>();

    for (GAU_Expenditure__c gauExpenditure : disbursement.GAU_Expendatures__r) {
      gauExpenditureWrapperlist.add(new GauExpenditureWrapper(gauExpenditure));
    }

    gauExpenditureWrappers = JSON.serialize(gauExpenditureWrapperlist);
  }

  public class GauExpenditureWrapper {
    Id recordId;
    Id disbursementId;
    Id gauId;
    String gauName;
    Decimal amount;

    public GauExpenditureWrapper(GAU_Expenditure__c gaue) {
      this.recordId = gaue.Id;
      this.disbursementId = gaue.Disbursement__c;
      this.gauId = gaue.General_Accounting_Unit__c;
      this.gauName = gaue.General_Accounting_Unit__r.Name;
      this.amount = gaue.Amount__c;
    }
  }
}
