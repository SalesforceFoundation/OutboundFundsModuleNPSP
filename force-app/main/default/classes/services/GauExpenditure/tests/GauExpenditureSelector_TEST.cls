@IsTest
public with sharing class GauExpenditureSelector_TEST {
    private static TestUser.MinimalAccessPersona minimalAccessPersona = new TestUser.MinimalAccessPersona();

    @TestSetup
    private static void testSetup() {
        TestUser.insertPersonasInTestSetup(
            new List<TestUser.Persona>{ GauExpenditureSelector_TEST.minimalAccessPersona }
        );

        GauExpenditureSelector_TEST.minimalAccessPersona.load();

        final outfunds__Funding_Request__c fundingRequest = new outfunds__Funding_Request__c(
            // Setting Test User as Owner to grant sharing access so we can test object-level and field-level permissions.
            OwnerId = GauExpenditureSelector_TEST.minimalAccessPersona.getUser().Id
        );
        insert fundingRequest;

        final outfunds__Disbursement__c disbursement = new outfunds__Disbursement__c(
            outfunds__Funding_Request__c = fundingRequest.Id,
            outfunds__Amount__c = 1000,
            outfunds__Status__c = 'Scheduled'
        );
        insert disbursement;

        final List<npsp__General_Accounting_Unit__c> generalAccountingUnits = new List<npsp__General_Accounting_Unit__c>{
            new npsp__General_Accounting_Unit__c(Name = 'GAU 0', npsp__Active__c = true),
            new npsp__General_Accounting_Unit__c(Name = 'GAU 1', npsp__Active__c = false),
            new npsp__General_Accounting_Unit__c(Name = 'GAU 2', npsp__Active__c = true),
            new npsp__General_Accounting_Unit__c(Name = 'GAU 3', npsp__Active__c = true),
            new npsp__General_Accounting_Unit__c(Name = 'GAU 4', npsp__Active__c = true),
            new npsp__General_Accounting_Unit__c(Name = 'GAU 5', npsp__Active__c = true)
        };
        insert generalAccountingUnits;

        final List<GAU_Expenditure__c> expenditures = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Disbursement__c = disbursement.Id,
                General_Accounting_Unit__c = generalAccountingUnits[0].Id,
                Amount__c = 700
            ),
            new GAU_Expenditure__c(
                Disbursement__c = disbursement.Id,
                General_Accounting_Unit__c = generalAccountingUnits[1].Id,
                Amount__c = 200
            ),
            new GAU_Expenditure__c(
                Disbursement__c = disbursement.Id,
                General_Accounting_Unit__c = generalAccountingUnits[2].Id,
                Amount__c = 100
            )
        };
        insert expenditures;
    }

    public static outfunds__Disbursement__c getDisbursement() {
        return [
            SELECT Id, (SELECT Id FROM GAU_Expendatures__r)
            FROM outfunds__Disbursement__c
            LIMIT 1
        ][0];
    }

    @IsTest
    private static void getDisbursementsById_WithPermissions() {
        final Id nullId;
        final Id nonDisbursementId = UnitTest.mockId(Schema.SObjectType.Account);
        final Id disbursementId = GauExpenditureSelector_TEST.getDisbursement().Id;

        Test.startTest();

        // Assert has permissions to read Disbursements, GAU Expenditures, and all fields since we are running as a user who can author Apex.
        System.assert(Schema.SObjectType.outfunds__Disbursement__c.isAccessible());
        System.assert(
            Schema.SObjectType.outfunds__Disbursement__c.fields.Name.isAccessible()
        );
        System.assert(
            Schema.SObjectType.outfunds__Disbursement__c.fields.outfunds__Amount__c.isAccessible()
        );
        System.assert(
            Schema.SObjectType.outfunds__Disbursement__c.fields.outfunds__Status__c.isAccessible()
        );

        System.assert(Schema.SObjectType.GAU_Expenditure__c.isAccessible());
        System.assert(
            Schema.SObjectType.GAU_Expenditure__c.fields.Amount__c.isAccessible()
        );
        System.assert(
            Schema.SObjectType.GAU_Expenditure__c.fields.General_Accounting_Unit__c.isAccessible()
        );

        System.assert(Schema.SObjectType.npsp__General_Accounting_Unit__c.isAccessible());
        System.assert(
            Schema.SObjectType.npsp__General_Accounting_Unit__c.fields.Name.isAccessible()
        );
        System.assert(
            Schema.SObjectType.npsp__General_Accounting_Unit__c.fields.npsp__Active__c.isAccessible()
        );

        // Run the test.
        final GauExpenditureSelector service = new GauExpenditureSelector();

        final List<outfunds__Disbursement__c> disbursementsWhenNullId = service.getDisbursementsById(
            nullId
        );

        final List<outfunds__Disbursement__c> disbursementsWhenNonDisbursementId = service.getDisbursementsById(
            nonDisbursementId
        );

        final List<outfunds__Disbursement__c> actual = service.getDisbursementsById(
            disbursementId
        );

        Test.stopTest();

        // When disbursementId is null.
        System.assertNotEquals(
            null,
            disbursementsWhenNullId,
            'GauExpenditureSelector.getDisbursementsById should never return null.'
        );

        System.assert(
            disbursementsWhenNullId.isEmpty(),
            'GauExpenditureSelector.getDisbursementsById should return empty when disbursementId is null.'
        );

        // When disbursementId does not belong to a non-deleted outfunds__Disbursement__c record.
        System.assertNotEquals(
            null,
            disbursementsWhenNonDisbursementId,
            'GauExpenditureSelector.getDisbursementsById should never return null.'
        );

        System.assert(
            disbursementsWhenNonDisbursementId.isEmpty(),
            'GauExpenditureSelector.getDisbursementsById should return empty when disbursementId does not belong to a non-deleted outfunds__Disbursement__c record.'
        );

        // When disbursementId DOES belong to a non-deleted outfunds__Disbursement__c record.
        System.assertNotEquals(
            null,
            actual,
            'GauExpenditureSelector.getDisbursementsById should never return null.'
        );

        System.assertEquals(
            1,
            actual.size(),
            'GauExpenditureSelector.getDisbursementsById should return one record.'
        );

        // Assert Disbursement with disbursementId was queried and Name, Amount, and Status fields are queried.
        System.assertEquals(disbursementId, actual[0].Id);
        System.assertNotEquals(null, actual[0].Name);
        System.assertEquals(1000, actual[0].outfunds__Amount__c);
        System.assertEquals('Scheduled', actual[0].outfunds__Status__c);

        System.assertEquals(3, actual[0].GAU_Expendatures__r.size());

        Map<String, GAU_Expenditure__c> expendituresByGauName = new Map<String, GAU_Expenditure__c>();
        for (GAU_Expenditure__c expenditure : actual[0].GAU_Expendatures__r) {
            expendituresByGauName.put(
                expenditure.General_Accounting_Unit__r.Name,
                expenditure
            );
        }

        {
            final GAU_Expenditure__c expenditure = expendituresByGauName.get('GAU 0');

            System.assertNotEquals(null, expenditure);
            System.assertEquals(
                true,
                expenditure.General_Accounting_Unit__r.npsp__Active__c
            );
            System.assertEquals(700, expenditure.Amount__c);
        }

        {
            final GAU_Expenditure__c expenditure = expendituresByGauName.get('GAU 1');

            System.assertNotEquals(null, expenditure);
            System.assertEquals(
                false,
                expenditure.General_Accounting_Unit__r.npsp__Active__c
            );
            System.assertEquals(200, expenditure.Amount__c);
        }

        {
            final GAU_Expenditure__c expenditure = expendituresByGauName.get('GAU 2');

            System.assertNotEquals(null, expenditure);
            System.assertEquals(
                true,
                expenditure.General_Accounting_Unit__r.npsp__Active__c
            );
            System.assertEquals(100, expenditure.Amount__c);
        }
    }

    @IsTest
    private static void getDisbursementsById_MissingDisbursementCrud() {
        // Set arguments.
        final Id disbursementId = GauExpenditureSelector_TEST.getDisbursement().Id;

        // Configure permissions.
        GauExpenditureSelector_TEST.minimalAccessPersona.load();

        Test.startTest();

        System.QueryException actualException;

        System.runAs(GauExpenditureSelector_TEST.minimalAccessPersona.getUser()) {
            // Assert Test User has expected permissions.
            System.assertEquals(
                false,
                Schema.outfunds__Disbursement__c.SObjectType.getDescribe().isAccessible()
            );
            System.assertEquals(
                false,
                Schema.outfunds__Disbursement__c.SObjectType.fields.Name.getDescribe()
                    .isAccessible()
            );
            System.assertEquals(
                false,
                Schema.outfunds__Disbursement__c.SObjectType.fields.outfunds__Amount__c.getDescribe()
                    .isAccessible()
            );
            System.assertEquals(
                false,
                Schema.outfunds__Disbursement__c.SObjectType.fields.outfunds__Status__c.getDescribe()
                    .isAccessible()
            );

            System.assertEquals(
                false,
                Schema.GAU_Expenditure__c.SObjectType.getDescribe().isAccessible()
            );
            System.assertEquals(
                false,
                Schema.GAU_Expenditure__c.SObjectType.fields.Amount__c.getDescribe()
                    .isAccessible()
            );
            System.assertEquals(
                false,
                Schema.GAU_Expenditure__c.SObjectType.fields.General_Accounting_Unit__c.getDescribe()
                    .isAccessible()
            );

            System.assertEquals(
                false,
                Schema.npsp__General_Accounting_Unit__c.SObjectType.getDescribe()
                    .isAccessible()
            );
            System.assertEquals(
                false,
                Schema.npsp__General_Accounting_Unit__c.SObjectType.fields.Name.getDescribe()
                    .isAccessible()
            );
            System.assertEquals(
                false,
                Schema.npsp__General_Accounting_Unit__c.SObjectType.fields.npsp__Active__c.getDescribe()
                    .isAccessible()
            );

            // Run the test.
            final GauExpenditureSelector service = new GauExpenditureSelector();

            try {
                service.getDisbursementsById(disbursementId);
            } catch (System.QueryException e) {
                actualException = e;
            }
        }

        Test.stopTest();

        System.assertNotEquals(
            null,
            actualException,
            'A System.QueryException should have been thrown because the user cannot read outfunds__Disbursement__c.'
        );
    }

    @IsTest
    private static void getExpendituresToDelete_WithPermissions() {
        // Set arguments and expected values.
        final outfunds__Disbursement__c disbursement = GauExpenditureSelector_TEST.getDisbursement();

        final Id nullDisbursementId;
        final Id nonDisbursementId = UnitTest.mockId(Schema.SObjectType.Account);
        final Id disbursementId = GauExpenditureSelector_TEST.getDisbursement();

        final Set<Id> nullExpenditureIdsToKeep;
        final Set<Id> emptyExpenditureIdsToKeep = new Set<Id>();
        final Set<Id> firstExpenditureIdsToKeep = new Set<Id>();

        final List<GAU_Expenditure__c> expected = new List<GAU_Expenditure__c>();

        {
            Boolean isFirst = true;
            for (GAU_Expenditure__c expenditure : disbursement.GAU_Expendatures__r) {
                if (isFirst) {
                    firstExpenditureIdsToKeep.add(expenditure.Id);
                    isFirst = false;
                } else {
                    expected.add(new GAU_Expenditure__c(Id = expenditure.Id));
                }
            }
        }

        Test.startTest();

        // Assert has permissions to read GAU Expenditures.
        System.assert(Schema.SObjectType.GAU_Expenditure__c.isAccessible());

        System.assert(
            Schema.SObjectType.GAU_Expenditure__c.fields.Disbursement__c.isAccessible()
        );

        // Run the test.
        final GauExpenditureSelector service = new GauExpenditureSelector();

        // An empty list should always be returned when disbursementId is null.
        for (
            Set<Id> expenditureIdsToKeep : new List<Set<Id>>{
                nullExpenditureIdsToKeep,
                emptyExpenditureIdsToKeep,
                firstExpenditureIdsToKeep
            }
        ) {
            final List<GAU_Expenditure__c> actual = selector.getExpendituresToDelete(
                nullDisbursementId,
                expenditureIdsToKeep
            );

            System.assertNotEquals(
                null,
                actual,
                'GauExpenditureSelector.getExpendituresToDelete should never return null.'
            );
            System.assert(
                actual.isEmpty(),
                'GauExpenditureSelector.getExpendituresToDelete should always return an empty list for a null disbursementId.'
            );
        }

        // An empty list should always be returned when disbursementId is not related to a non-deleted Disbursement record.
        for (
            Set<Id> expenditureIdsToKeep : new List<Set<Id>>{
                nullExpenditureIdsToKeep,
                emptyExpenditureIdsToKeep,
                firstExpenditureIdsToKeep
            }
        ) {
            final List<GAU_Expenditure__c> actual = selector.getExpendituresToDelete(
                nonDisbursementId,
                expenditureIdsToKeep
            );

            System.assertNotEquals(
                null,
                actual,
                'GauExpenditureSelector.getExpendituresToDelete should never return null.'
            );
            System.assert(
                actual.isEmpty(),
                'GauExpenditureSelector.getExpendituresToDelete should always return an empty list for a disbursementId not related to a non-deleted Disbursement record.'
            );
        }

        final List<GAU_Expenditure__c> actualWhenNullExpenditureIdsToKeep = selector.getExpendituresToDelete(
            disbursementId,
            nullExpenditureIdsToKeep
        );

        final List<GAU_Expenditure__c> actualWhenEmptyExpenditureIdsToKeep = selector.getExpendituresToDelete(
            disbursementId,
            emptyExpenditureIdsToKeep
        );

        final List<GAU_Expenditure__c> actualWhenFirstExpenditureIdsToKeep = selector.getExpendituresToDelete(
            disbursementId,
            firstExpenditureIdsToKeep
        );

        Test.stopTest();

        // actualWhenNullExpenditureIdsToKeep.
        System.assertNotEquals(
            null,
            actualWhenNullExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should never return null.'
        );
        System.assertEquals(
            disbursement.GAU_Expenditures__r,
            actualWhenNullExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should return all list of child GAU Expenditure.'
        );

        // actualWhenEmptyExpenditureIdsToKeep.
        System.assertNotEquals(
            null,
            actualWhenEmptyExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should never return null.'
        );
        System.assertEquals(
            disbursement.GAU_Expenditures__r,
            actualWhenEmptyExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should return all list of child GAU Expenditure.'
        );

        // actualWhenFirstExpenditureIdsToKeep.
        System.assertNotEquals(
            null,
            actualWhenFirstExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should never return null.'
        );
        System.assertEquals(
            expected,
            actualWhenFirstExpenditureIdsToKeep,
            'GauExpenditureSelector.getExpendituresToDelete should return only the last two children GAU Expenditure.'
        );
    }

    @IsTest
    private static void getExpendituresToDelete_MissingDisbursementCrud() {
        // Set arguments.
        final Id disbursementId = GauExpenditureSelector_TEST.getDisbursement().Id;
        final Set<Id> expenditureIdsToKeep = new Set<Id>();

        // Configure permissions.
        GauExpenditureSelector_TEST.minimalAccessPersona.load();

        Test.startTest();

        System.QueryException actualException;

        System.runAs(GauExpenditureSelector_TEST.minimalAccessPersona.getUser()) {
            // Assert Test User has expected permissions.
            System.assertEquals(
                false,
                Schema.GAU_Expenditure__c.SObjectType.getDescribe().isAccessible()
            );

            System.assert(
                Schema.SObjectType.GAU_Expenditure__c.fields.Disbursement__c.isAccessible()
            );

            // Run the test.
            final GauExpenditureSelector service = new GauExpenditureSelector();

            try {
                service.getExpendituresToDelete(disbursementId, expenditureIdsToKeep);
            } catch (System.QueryException e) {
                actualException = e;
            }
        }

        Test.stopTest();

        System.assertNotEquals(
            null,
            actualException,
            'A System.QueryException should have been thrown because the user cannot read GAU_Expenditure__c.'
        );
    }
}
