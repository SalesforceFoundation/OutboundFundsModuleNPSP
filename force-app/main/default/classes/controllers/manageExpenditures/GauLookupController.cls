/*******************************************************************************
 * @author Thom Behrens
 * @date 2019-11-16
 *
 * @description Class containing LWC exposed static search methods & helpers
 */
public with sharing class GauLookupController {
    /*****************************************************************************
     * @description dictates maximum number of results returned from query
     */
    public final static Integer MAX_RESULTS = 5;

    /*****************************************************************************
     * @description dictates icon to be used alongside results - see link below
     * https://www.lightningdesignsystem.com/icons/
     */
    public final static String ICON_NAME = 'custom:custom87';

    /*****************************************************************************
     * @description search npsp__General_Accounting_Unit__c records
     * @param searchTerm: String to be used to match against records
     * @param selectedIds: Optional List of Ids to exclude (w/ multi-select lookup)
     * @return List<LookupSearchResult> wrappers to give to component
     * @example
     */
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(
        String searchTerm,
        List<String> selectedIds
    ) {
        searchTerm = String.escapeSingleQuotes(searchTerm) + '%';
        List<npsp__General_Accounting_Unit__c> gaus = [
            SELECT Name, Id, npsp__Description__c
            FROM npsp__General_Accounting_Unit__c
            WHERE Name LIKE :searchTerm AND npsp__Active__c = TRUE
            LIMIT :MAX_RESULTS
        ];

        List<LookupSearchResult> lookupSearchResults = new List<LookupSearchResult>();
        for (npsp__General_Accounting_Unit__c eachGau : gaus) {
            lookupSearchResults.add(
                new lookupSearchResult(
                    eachGau.Id,
                    'npsp__General_Accounting_Unit__c',
                    ICON_NAME,
                    eachGau.Name,
                    eachGau.npsp__Description__c
                )
            );
        }

        return lookupSearchResults;
    }
}
