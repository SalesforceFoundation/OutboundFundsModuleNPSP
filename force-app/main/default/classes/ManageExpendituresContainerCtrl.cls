public with sharing class ManageExpendituresContainerCtrl {
  /** @description The Id of the parent Disbursement */
  public Id parentId { get; set; }

  /** @description The Name of the parent Disbursement */
  public String parentName { get; set; }

  /** @description List of expenditures, represented in JSON */
  public String gauExpenditures { get; set; }

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
          SELECT Id, Name, General_Accounting_Unit__c, Amount__c
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

    // TODO: stringify
    gauExpenditures = JSON.serialize(disbursement.GAU_Expendatures__r);
  }
}
