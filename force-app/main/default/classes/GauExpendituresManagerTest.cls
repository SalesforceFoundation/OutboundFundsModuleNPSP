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

  /*****************************************************************************
   * @description Test expected use case of retrieving disbursement with several expenditures
   */
  @IsTest
  public static void validGetDisbursement() {
    outfunds__Disbursement__c disbursement = makeData();
    List<npsp__General_Accounting_Unit__c> gaus = createGaus('GAU', 5);
    List<GAU_Expenditure__c> gauExpenditures = createGauExpenditures(
      disbursement.Id,
      gaus
    );
    Test.startTest();
    GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      String.valueOf(disbursement.Id)
    );
    Test.stopTest();
    system.assertEquals(
      10000,
      queriedDisbursement.amount,
      'expected disbursement amount of 10000'
    );
    system.assertEquals(
      5,
      queriedDisbursement.expenditures.size(),
      'expected list of 5 expenditures'
    );
    System.debug('hello world');
  }

  /*****************************************************************************
   * @description Test case of no disbursement returned due to invalid Id
   */
  @IsTest
  public static void badIdGetDisbursement() {
    Test.startTest();
    GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      'I am not a record Id'
    );
    Test.stopTest();
    System.assertEquals(null, queriedDisbursement, 'expected null');
  }

  /*****************************************************************************
   * @description Test update ability of new GAU Expenditure wrappers added
   */
  @IsTest
  public static void testValidUpdate() {
    outfunds__Disbursement__c disbursement = makeData();
    List<npsp__General_Accounting_Unit__c> gaus = createGaus('GAU', 5);
    List<GAU_Expenditure__c> gauExpenditures = createGauExpenditures(
      disbursement.Id,
      gaus
    );
    GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      String.valueOf(disbursement.Id)
    );
    // test update ability of list items
    for (
      GauExpendituresManager.GauExpenditureWrapper expenditure : queriedDisbursement.expenditures
    ) {
      expenditure.amount = 56.78;
    }
    String expendituresString = JSON.serialize(
      queriedDisbursement.expenditures
    );
    Test.startTest();
    GauExpendituresManager.upsertGauExpenditures(
      expendituresString,
      disbursement.Id
    );
    Test.stopTest();
    List<GAU_Expenditure__c> queriedExpenditures = [
      SELECT Id, Amount__c, Disbursement__c
      FROM GAU_Expenditure__c
    ];
    /* System.assertEquals(
      6,
      queriedExpenditures.size(),
      'expected 6 expenditures'
    ); */
    for (GAU_Expenditure__c queriedExpenditure : queriedExpenditures) {
      System.assertEquals(
        disbursement.Id,
        queriedExpenditure.Disbursement__c,
        'expected matching disbursement id'
      );
      System.assertEquals(
        56.78,
        queriedExpenditure.Amount__c,
        'amount did not match assign values'
      );
    }
  }
  /*****************************************************************************
   * @description Test insert ability of new GAU Expenditure wrappers added
   */
  @IsTest
  public static void testValidInsert() {
    outfunds__Disbursement__c disbursement = makeData();
    List<npsp__General_Accounting_Unit__c> gaus = createGaus('GAU', 5);
    List<GAU_Expenditure__c> gauExpenditures = createGauExpenditures(
      disbursement.Id,
      gaus
    );
    GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      String.valueOf(disbursement.Id)
    );
    List<npsp__General_Accounting_Unit__c> newGaus = createGaus('newGAU', 1);

    GauExpendituresManager.GauExpenditureWrapper newExpenditureWrapper = new GauExpendituresManager.GauExpenditureWrapper(
      new GAU_Expenditure__c(General_Accounting_Unit__c = newGaus[0].Id),
      1
    );
    queriedDisbursement.expenditures.add(newExpenditureWrapper);
    String expendituresString = JSON.serialize(
      queriedDisbursement.expenditures
    );
    GauExpendituresManager.upsertGauExpenditures(
      expendituresString,
      disbursement.Id
    );
    List<GAU_Expenditure__c> queriedExpenditures = [
      SELECT Id, Disbursement__c
      FROM GAU_Expenditure__c
    ];
    System.assertEquals(
      6,
      queriedExpenditures.size(),
      'expected 6 expenditures'
    );
    for (GAU_Expenditure__c expenditure : queriedExpenditures) {
      System.assertEquals(
        disbursement.Id,
        expenditure.Disbursement__c,
        'Disbursement Id does not match'
      );
    }
  }
  /*****************************************************************************
   * @description Test delete ability of new GAU Expenditure wrappers added
   */
  @IsTest
  public static void testValidDelete() {
    outfunds__Disbursement__c disbursement = makeData();
    List<npsp__General_Accounting_Unit__c> gaus = createGaus('GAU', 5);
    List<GAU_Expenditure__c> gauExpenditures = createGauExpenditures(
      disbursement.Id,
      gaus
    );
    GauExpendituresManager.DisbursementWrapper queriedDisbursement = GauExpendituresManager.getDisbursement(
      String.valueOf(disbursement.Id)
    );

    List<GauExpendituresManager.GauExpenditureWrapper> newExpendituresList = new List<GauExpendituresManager.GauExpenditureWrapper>{
      queriedDisbursement.expenditures[0]
    };

    String expendituresString = JSON.serialize(newExpendituresList);
    GauExpendituresManager.upsertGauExpenditures(
      expendituresString,
      disbursement.Id
    );
    List<GAU_Expenditure__c> queriedExpenditures = [
      SELECT Id, Disbursement__c
      FROM GAU_Expenditure__c
    ];
    System.assertEquals(
      1,
      queriedExpenditures.size(),
      'expected 1 expenditure'
    );
    for (GAU_Expenditure__c expenditure : queriedExpenditures) {
      System.assertEquals(
        disbursement.Id,
        expenditure.Disbursement__c,
        'Disbursement Id does not match'
      );
    }
  }
}
