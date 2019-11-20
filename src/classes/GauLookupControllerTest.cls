@IsTest
public with sharing class GauLookupControllerTest {
  @IsTest
  public static void happyPath() {
    insert new npsp__General_Accounting_Unit__c(Name = 'Unit 1');
    Test.startTest();
    List<LookupSearchResult> lookupSearchResults = GauLookupController.search(
      'Unit 1',
      new List<Id>()
    );
    Test.stopTest();
    System.assertEquals(
      1,
      lookupSearchResults.size(),
      'Wrong number of search results'
    );
  }

  @IsTest
  public static void testMaxResults() {
    List<npsp__General_Accounting_Unit__c> gaus = new List<npsp__General_Accounting_Unit__c>();
    Integer tooMany = GauLookupController.MAX_RESULTS + 1;
    for (Integer itr = 0; itr < tooMany; itr++) {
      gaus.add(
        new npsp__General_Accounting_Unit__c(
          Name = 'Unit ' + String.valueof(DateTime.now().getTime())
        )
      );
    }
    insert gaus;
    Test.startTest();
    List<LookupSearchResult> lookupSearchResults = GauLookupController.search(
      'Unit',
      new List<Id>()
    );
    Test.stopTest();
    System.assertEquals(
      GauLookupController.MAX_RESULTS,
      lookupSearchResults.size(),
      'Wrong number of search results'
    );
  }
}
