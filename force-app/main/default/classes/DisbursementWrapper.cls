public with sharing class DisbursementWrapper {
  @AuraEnabled
  public Id recordId { get; set; }
  @AuraEnabled
  public String name { get; set; }
  @AuraEnabled
  public Decimal amount { get; set; }
  public DisbursementWrapper(outfunds__Disbursement__c disbursement) {
    this.recordId = disbursement.Id;
    this.name = disbursement.Name;
    this.amount = disbursement.outfunds__Amount__c;
  }
}
