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
  public static void testInactive() {
    insert new npsp__General_Accounting_Unit__c(
      Name = 'Unit 1',
      npsp__Active__c = false
    );
    Test.startTest();
    List<LookupSearchResult> lookupSearchResults = GauLookupController.search(
      'Unit 1',
      new List<Id>()
    );
    Test.stopTest();
    System.assertEquals(
      0,
      lookupSearchResults.size(),
      'did not expect to receive inactive GAUs'
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

  @IsTest
  public static void testGetters() {
    npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(
      Name = 'Unit 1',
      npsp__Description__c =
        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.'
    );
    insert gau;
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
    LookupSearchResult result = lookupSearchResults[0];
    System.assertEquals(
      gau.Id,
      result.getId(),
      'getId() failed to load correct id.'
    );
    System.assertEquals(
      'npsp__General_Accounting_Unit__c',
      result.getSObjectType(),
      'Wrong SObject type provided'
    );
    System.assertEquals(
      GauLookupController.ICON_NAME,
      result.getIcon(),
      'Wrong icon provided'
    );
    System.assertEquals(gau.Name, result.getTitle(), 'Wrong title provided');
    System.assertEquals(
      gau.npsp__Description__c,
      result.getSubtitle(),
      'Wrong subtitle provided'
    );
  }
}
