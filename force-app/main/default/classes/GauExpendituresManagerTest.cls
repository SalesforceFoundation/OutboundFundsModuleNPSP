@IsTest
public with sharing class GauExpendituresManagerTest {
  /*****************************************************************************
   * @description Create records needed for test and set class-level properties
   */
  public static outfunds__Disbursement__c makeData() {
    outfunds__Funding_Program__c fundingProgram = new outfunds__Funding_Program__c(
      Name = 'My Funding Program'
    );
    insert fundingProgram;
    outfunds__Funding_Request__c fundingRequest = new outfunds__Funding_Request__c(
      Name = 'My Funding Request',
      outfunds__FundingProgram__c = fundingProgram.Id
    );
    insert fundingRequest;
    outfunds__Disbursement__c disbursement = new outfunds__Disbursement__c(
      outfunds__Amount__c = 10000,
      outfunds__Funding_Request__c = fundingRequest.Id
    );
    insert disbursement;
    return disbursement;
  }

  /*****************************************************************************
   * @description Create specified number of gaus with signifier in name
   */
  public static List<npsp__General_Accounting_Unit__c> createGaus(
    String namePrefix,
    Integer count
  ) {
    Integer max = count > 200 ? 200 : count;
    List<npsp__General_Accounting_Unit__c> gaus = new List<npsp__General_Accounting_Unit__c>();
    for (Integer itr = 0; itr < count; itr++) {
      gaus.add(
        new npsp__General_Accounting_Unit__c(
          Name = namePrefix + '-' + String.valueOf(DateTime.now().getTime())
        )
      );
    }
    insert gaus;
    return gaus;
  }
  /*****************************************************************************
   * @description Create one expenditure for each gau, and link to disbursement
   */
  public static List<GAU_Expenditure__c> createGauExpenditures(
    Id disbursementId,
    List<npsp__General_Accounting_Unit__c> gaus
  ) {
    List<GAU_Expenditure__c> gauExpenditures = new List<GAU_Expenditure__c>();
    for (npsp__General_Accounting_Unit__c gau : gaus) {
      gauExpenditures.add(
        new GAU_Expenditure__c(
          Disbursement__c = disbursementId,
          General_Accounting_Unit__c = gau.Id
        )
      );
    }
    insert gauExpenditures;
    return gauExpenditures;
  }

  @IsTest
  public static void validGetDisbursement() {
    outfunds__Disbursement__c disbursement = makeData();
    List<npsp__General_Accounting_Unit__c> gaus = createGaus('GAU', 5);
    List<GAU_Expenditure__c> gauExpenditures = createGauExpenditures(
      disbursement.Id,
      gaus
    );
    Test.startTest();
    DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      String.valueOf(disbursement.Id)
    );
    Test.stopTest();
    system.assertEquals(
      10000,
      queriedDisbursement.amount,
      'expected disbursement amount of 10000'
    );
    /* system.assertEquals(
      5,
      queriedDisbursement.GAU_Expendatures__r.size(),
      'expected list of 5 expenditures'
    ); */
    System.debug('hello world');
  }

  @IsTest
  public static void badIdGetDisbursement() {
    Test.startTest();
    DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      'I am not a record Id'
    );
    Test.stopTest();
    System.assertEquals(null, queriedDisbursement, 'expected null');
  }
}
