@IsTest
public with sharing class GauExpendituresManager_TEST {
    public static void assertEquals(
        GauExpendituresManager.GauExpenditureWrapper expected,
        GauExpendituresManager.GauExpenditureWrapper actual,
        Integer index
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);

            final String messageSuffix = index == null ? '' : ' at index "' + index + '"';

            System.assertEquals(
                expected.recordId,
                actual.recordId,
                'GauExpenditureWrapper.recordId' + messageSuffix
            );
            System.assertEquals(
                expected.gauId,
                actual.gauId,
                'GauExpenditureWrapper.gauId' + messageSuffix
            );
            System.assertEquals(
                expected.gauName,
                actual.gauName,
                'gauName' + messageSuffix
            );
            System.assertEquals(
                expected.amount,
                actual.amount,
                'GauExpenditureWrapper.amount' + messageSuffix
            );
            System.assertEquals(
                expected.gauIsActive,
                actual.gauIsActive,
                'gauIsActive' + messageSuffix
            );
            System.assertEquals(
                expected.rowId,
                actual.rowId,
                'GauExpenditureWrapper.rowId' + messageSuffix
            );
        }
    }

    public static void assertEquals(
        List<GauExpendituresManager.GauExpenditureWrapper> expected,
        List<GauExpendituresManager.GauExpenditureWrapper> actual
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);

            final Integer expendituresSize = expected.size();
            System.assertEquals(
                expendituresSize,
                actual.size(),
                'List<GauExpenditureWrapper>.size()'
            );

            for (Integer i = 0; i < expendituresSize; i++) {
                GauExpendituresManager_TEST.assertEquals(expected[i], actual[i], i);
            }
        }
    }

    public static void assertEquals(
        GauExpendituresManager.DisbursementWrapper expected,
        GauExpendituresManager.DisbursementWrapper actual
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);
            System.assertEquals(
                expected.recordId,
                actual.recordId,
                'DisbursementWrapper.recordId'
            );
            System.assertEquals(expected.name, actual.name, 'DisbursementWrapper.name');
            System.assertEquals(
                expected.amount,
                actual.amount,
                'DisbursementWrapper.amount'
            );
            System.assertEquals(
                expected.status,
                actual.status,
                'DisbursementWrapper.status'
            );

            GauExpendituresManager_TEST.assertEquals(
                expected.expenditures,
                actual.expenditures
            );
        }
    }

    public static void assertEquals(
        GauExpendituresManager.LookupSearchResult expected,
        GauExpendituresManager.LookupSearchResult actual,
        Integer index
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);

            final String messageSuffix = index == null ? '' : ' at index "' + index + '"';

            System.assertEquals(
                expected.id,
                actual.id,
                'LookupSearchResult.id' + messageSuffix
            );
            System.assertEquals(
                expected.sObjectType,
                actual.sObjectType,
                'LookupSearchResult.sObjectType' + messageSuffix
            );
            System.assertEquals(
                expected.icon,
                actual.icon,
                'LookupSearchResult.icon' + messageSuffix
            );
            System.assertEquals(
                expected.title,
                actual.title,
                'LookupSearchResult.title' + messageSuffix
            );
            System.assertEquals(
                expected.subtitle,
                actual.subtitle,
                'LookupSearchResult.subtitle' + messageSuffix
            );
        }
    }

    public static void assertEquals(
        List<GauExpendituresManager.LookupSearchResult> expected,
        List<GauExpendituresManager.LookupSearchResult> actual
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);

            final Integer expendituresSize = expected.size();
            System.assertEquals(
                expendituresSize,
                actual.size(),
                'List<LookupSearchResult>.size()'
            );

            for (Integer i = 0; i < expendituresSize; i++) {
                GauExpendituresManager_TEST.assertEquals(expected[i], actual[i], i);
            }
        }
    }

    @IsTest
    private static void GauExpenditureWrapper_NonNullGauId() {
        final String gauExpenditureObjectName = Schema.SObjectType.GAU_Expenditure__c.getName();
        final String disbursementFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Disbursement__c.getName();
        final String amountFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Amount__c.getName();
        final String gauFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.General_Accounting_Unit__c.getName();
        final String gauRelationshipName = gauFieldName.removeEnd('__c') + '__r';

        final Id recordId = 'a0x9A000000ASvfQAG';
        final Id gauId = 'a0d9A0000003r1sQAA';
        final String gauName = 'Area of most need';
        final Decimal amount = 1250.0;
        final Boolean gauIsActive = true;

        // prettier-ignore
        final GAU_Expenditure__c gauExpenditure = (GAU_Expenditure__c) JSON.deserialize(
            String.join(
                new List<String> {
                    '{',
                        '"attributes": {',
                            '"type": "' + gauExpenditureObjectName + '",',
                            '"url": "/services/data/v51.0/sobjects/' + gauExpenditureObjectName + '/' + recordId + '"',
                        '},',
                        '"' + disbursementFieldName+ '": "a0s9A000000cuCSQAY",',
                        '"Id": "' + recordId + '",',
                        '"' + gauFieldName + '": "' + gauId + '",',
                        '"'+ amountFieldName + '": ' + amount.toPlainString() + ',',
                        '"' + gauRelationshipName + '": {',
                            '"attributes": {',
                                '"type": "npsp__General_Accounting_Unit__c",',
                                '"url": "/services/data/v51.0/sobjects/npsp__General_Accounting_Unit__c/' + gauId + '"',
                            '},',
                            '"Id": "' + gauId + '",',
                            '"Name": "' + gauName + '",',
                            '"npsp__Active__c": ' + gauIsActive + '',
                        '}',
                    '}'
                },
                ''
            ),
            GAU_Expenditure__c.class
        );
        final Integer rowId = Crypto.getRandomInteger();

        Test.startTest();

        final GauExpendituresManager.GauExpenditureWrapper actual = new GauExpendituresManager.GauExpenditureWrapper(
            gauExpenditure,
            rowId
        );

        Test.stopTest();

        System.assertEquals(recordId, actual.recordId);
        System.assertEquals(gauId, actual.gauId);
        System.assertEquals(gauName, actual.gauName);
        System.assertEquals(amount, actual.amount);
        System.assertEquals(gauIsActive, actual.gauIsActive);
        System.assertEquals(rowId, actual.rowId);
    }

    @IsTest
    private static void GauExpenditureWrapper_NullGauId() {
        final String gauExpenditureObjectName = Schema.SObjectType.GAU_Expenditure__c.getName();
        final String disbursementFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Disbursement__c.getName();
        final String amountFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Amount__c.getName();

        final Id recordId = 'a0x9A000000ASvfQAG';
        final Id gauId = null;
        final String gauName = null;
        final Decimal amount = 1250.0;
        final Boolean gauIsActive = false;

        // prettier-ignore
        final GAU_Expenditure__c gauExpenditure = (GAU_Expenditure__c) JSON.deserialize(
            String.join(
                new List<String> {
                    '{',
                        '"attributes": {',
                            '"type": "' + gauExpenditureObjectName + '",',
                            '"url": "/services/data/v51.0/sobjects/' + gauExpenditureObjectName + '/' + recordId + '"',
                        '},',
                        '"' + disbursementFieldName + '": "a0s9A000000cuCSQAY",',
                        '"Id": "' + recordId + '",',
                        '"' + amountFieldName + '": ' + amount.toPlainString() + '',
                    '}'
                },
                ''
            ),
            GAU_Expenditure__c.class
        );
        final Integer rowId = Crypto.getRandomInteger();

        Test.startTest();

        final GauExpendituresManager.GauExpenditureWrapper actual = new GauExpendituresManager.GauExpenditureWrapper(
            gauExpenditure,
            rowId
        );

        Test.stopTest();

        System.assertEquals(recordId, actual.recordId);
        System.assertEquals(gauId, actual.gauId);
        System.assertEquals(gauName, actual.gauName);
        System.assertEquals(amount, actual.amount);
        System.assertEquals(gauIsActive, actual.gauIsActive);
        System.assertEquals(rowId, actual.rowId);
    }

    @IsTest
    private static void DisbursementWrapper() {
        final String gauExpenditureObjectName = Schema.SObjectType.GAU_Expenditure__c.getName();
        final String disbursementFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Disbursement__c.getName();
        final String amountFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.Amount__c.getName();
        final String gauFieldName = Schema.SObjectType.GAU_Expenditure__c.fields.General_Accounting_Unit__c.getName();
        final String gauRelationshipName = gauFieldName.removeEnd('__c') + '__r';

        final Id gauExpenditureId1 = UnitTest.mockId(
            Schema.SObjectType.GAU_Expenditure__c
        );
        final Id gauId1 = UnitTest.mockId(
            Schema.SObjectType.npsp__General_Accounting_Unit__c
        );

        final Id gauExpenditureId2 = UnitTest.mockId(
            Schema.SObjectType.GAU_Expenditure__c
        );

        Schema.ChildRelationship gauExpenditureChildRelationship;
        for (
            Schema.ChildRelationship childRelationship : Schema.SObjectType.outfunds__Disbursement__c.getChildRelationships()
        ) {
            if (
                Schema.GAU_Expenditure__c.SObjectType ==
                childRelationship.getChildSObject() &&
                Schema.GAU_Expenditure__c.SObjectType.fields.Disbursement__c ==
                childRelationship.getField()
            ) {
                gauExpenditureChildRelationship = childRelationship;
                break;
            }
        }
        System.assertNotEquals(
            null,
            gauExpenditureChildRelationship,
            'No outfunds__Disbursement__c Child Relationship to GAU_Expenditure__c.Disbursement__c found.'
        );
        final String gauExpenditureRelationshipName = gauExpenditureChildRelationship.getRelationshipName();

        final Id recordId = UnitTest.mockId(Schema.SObjectType.outfunds__Disbursement__c);
        final String name = 'D-00004';
        final Decimal amount = 314159.27;
        final String status = 'Scheduled';

        // prettier-ignore
        final String gauExpenditure1Json = String.join(
            new List<String> {
                '{',
                    '"attributes": {',
                        '"type": "' + gauExpenditureObjectName + '",',
                        '"url": "/services/data/v51.0/sobjects/' + gauExpenditureObjectName + '/' + gauExpenditureId1 + '"',
                    '},',
                    '"' + disbursementFieldName + '": "a0s9A000000cuCSQAY",',
                    '"Id": "' + gauExpenditureId1 + '",',
                    '"' + gauFieldName + '": "' + gauId1 + '",',
                    '"'+ amountFieldName + '": 1234.5,',
                    '"' + gauRelationshipName + '": {',
                        '"attributes": {',
                            '"type": "npsp__General_Accounting_Unit__c",',
                            '"url": "/services/data/v51.0/sobjects/npsp__General_Accounting_Unit__c/' + gauId1 + '"',
                        '},',
                        '"Id": "' + gauId1 + '",',
                        '"Name": "GAU 1",',
                        '"npsp__Active__c": true',
                    '}',
                '}'
            },
            ''
        );
        final GAU_Expenditure__c gauExpenditure1 = (GAU_Expenditure__c) JSON.deserialize(
            gauExpenditure1Json,
            GAU_Expenditure__c.class
        );

        // prettier-ignore
        final String gauExpenditure2Json = String.join(
            new List<String> {
                '{',
                    '"attributes": {',
                        '"type": "' + gauExpenditureObjectName + '",',
                        '"url": "/services/data/v51.0/sobjects/' + gauExpenditureObjectName + '/' + gauExpenditureId2 + '"',
                    '},',
                    '"' + disbursementFieldName+ '": "a0s9A000000cuCSQAY",',
                    '"Id": "' + gauExpenditureId2 + '",',
                    '"'+ amountFieldName + '": 5432.1',
                '}'
            },
            ''
        );
        final GAU_Expenditure__c gauExpenditure2 = (GAU_Expenditure__c) JSON.deserialize(
            gauExpenditure2Json,
            GAU_Expenditure__c.class
        );
        final List<GAU_Expenditure__c> expenditures = new List<GAU_Expenditure__c>{
            gauExpenditure1,
            gauExpenditure2
        };

        final List<GauExpendituresManager.GauExpenditureWrapper> expectedExpenditures = new List<GauExpendituresManager.GauExpenditureWrapper>{
            new GauExpendituresManager.GauExpenditureWrapper(gauExpenditure1, 1),
            new GauExpendituresManager.GauExpenditureWrapper(gauExpenditure2, 2)
        };

        // prettier-ignore
        final outfunds__Disbursement__c disbursement = (outfunds__Disbursement__c) JSON.deserialize(
            String.join(
                new List<String> {
                    '{',
                        '"attributes": {',
                            '"type": "outfunds__Disbursement__c",',
                            '"url": "/services/data/v51.0/sobjects/outfunds__Disbursement__c/' + recordId + '"',
                        '},',
                        '"Id": "' + recordId + '",',
                        '"Name": "' + name + '",',
                        '"outfunds__Amount__c": ' + amount.toPlainString() + ',',
                        '"outfunds__Status__c": "' + status + '",',
                        '"' + gauExpenditureRelationshipName + '": {',
                            '"totalSize": ' + expenditures.size() + ',',
                            '"done": true,',
                            '"records": [',
                                gauExpenditure1Json + ',',
                                gauExpenditure2Json,
                            ']',
                        '}',
                    '}'
                },
                ''
            ),
            outfunds__Disbursement__c.class
        );
        Test.startTest();

        final GauExpendituresManager.DisbursementWrapper actual = new GauExpendituresManager.DisbursementWrapper(
            disbursement
        );

        Test.stopTest();

        System.assertEquals(recordId, actual.recordId);
        System.assertEquals(name, actual.name);
        System.assertEquals(amount, actual.amount);
        System.assertEquals(status, actual.status);
        GauExpendituresManager_TEST.assertEquals(
            expectedExpenditures,
            actual.expenditures
        );
    }

    @IsTest
    private static void getDisbursement_QueryFindsNoRecords() {
        // Set arguments, mock return values, and expected values.
        final String disbursementId = 'disbursementId';
        final GauExpendituresManager.DisbursementWrapper expected;
        final List<outfunds__Disbursement__c> disbursements = new List<outfunds__Disbursement__c>();

        // Set mocks
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getDisbursementsById = gauExpenditureSelector.getMethod(
            'getDisbursementsById'
        );
        getDisbursementsById.returnValue = disbursements;

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        final GauExpendituresManager.DisbursementWrapper actual = GauExpendituresManager.getDisbursement(
            disbursementId
        );

        Test.stopTest();

        System.assertEquals(
            expected,
            actual,
            'GauExpendituresManager.getDisbursement should return null if gauExpenditureSelector.getDisbursementsById returns no records.'
        );

        getDisbursementsById.assertCalledOnceWith(new List<Object>{ disbursementId });
    }

    @IsTest
    private static void getDisbursement_QueryFindsRecords() {
        // Set arguments, mock return values, and expected values.
        final String disbursementId = 'disbursementId';
        final List<outfunds__Disbursement__c> disbursements = new List<outfunds__Disbursement__c>{
            new outfunds__Disbursement__c(
                Id = UnitTest.mockId(Schema.SObjectType.outfunds__Disbursement__c)
            )
        };
        final GauExpendituresManager.DisbursementWrapper expected = new GauExpendituresManager.DisbursementWrapper(
            disbursements[0]
        );

        // Set mocks
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getDisbursementsById = gauExpenditureSelector.getMethod(
            'getDisbursementsById'
        );
        getDisbursementsById.returnValue = disbursements;

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        final GauExpendituresManager.DisbursementWrapper actual = GauExpendituresManager.getDisbursement(
            disbursementId
        );

        Test.stopTest();

        GauExpendituresManager_TEST.assertEquals(expected, actual);

        getDisbursementsById.assertCalledOnceWith(new List<Object>{ disbursementId });
    }

    @IsTest
    private static void getDisbursement_QueryThrowsException() {
        // Set arguments, mock return values, and expected values.
        final String disbursementId = 'disbursementId';
        final List<outfunds__Disbursement__c> disbursements = new List<outfunds__Disbursement__c>{
            new outfunds__Disbursement__c(
                Id = UnitTest.mockId(Schema.SObjectType.outfunds__Disbursement__c)
            )
        };

        // Set mocks
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getDisbursementsById = gauExpenditureSelector.getMethod(
            'getDisbursementsById'
        );
        getDisbursementsById.returnValue = new UnitTest.TestException(
            'This is only a test'
        );

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        System.AuraHandledException actualException;

        try {
            GauExpendituresManager.getDisbursement(disbursementId);
        } catch (System.AuraHandledException e) {
            actualException = e;
        }

        Test.stopTest();

        System.assertNotEquals(
            null,
            actualException,
            'getDisbursementsById should have thrown an Exception so getDisbursement should have re-thrown the Exception as a System.AuraHandledException.'
        );
        System.assertEquals(
            'This is only a test',
            actualException.getMessage(),
            'getDisbursementsById should have thrown an Exception so getDisbursement should have re-thrown the Exception as a System.AuraHandledException with the same message.'
        );

        getDisbursementsById.assertCalledOnceWith(new List<Object>{ disbursementId });
    }

    @IsTest
    private static void upsertGauExpenditures_DeletesUpdatesAndInserts() {
        // Set arguments, mock return values, and expected values.
        final Id disbursementId = UnitTest.mockId(
            Schema.SObjectType.outfunds__Disbursement__c
        );

        final List<GAU_Expenditure__c> expectedExpendituresToInsert = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Id = (Id) null,
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 0
            ),
            new GAU_Expenditure__c(
                Id = (Id) null,
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 2
            )
        };

        final List<GAU_Expenditure__c> expectedExpendituresToUpdate = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Id = UnitTest.mockId(Schema.SObjectType.GAU_Expenditure__c),
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 1
            )
        };

        List<GauExpendituresManager.GauExpenditureWrapper> expenditureWrappers = new List<GauExpendituresManager.GauExpenditureWrapper>();
        for (
            GAU_Expenditure__c expenditure : new List<GAU_Expenditure__c>{
                expectedExpendituresToInsert[0],
                expectedExpendituresToUpdate[0],
                expectedExpendituresToInsert[1]
            }
        ) {
            final GauExpendituresManager.GauExpenditureWrapper wrapper = new GauExpendituresManager.GauExpenditureWrapper();
            wrapper.recordId = expenditure.Id;
            wrapper.gauId = expenditure.General_Accounting_Unit__c;
            wrapper.amount = expenditure.Amount__c;

            expenditureWrappers.add(wrapper);
        }

        final String expendituresString = JSON.serialize(expenditureWrappers);

        // Set mocks.
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getExpendituresToDelete = gauExpenditureSelector.getMethod(
            'getExpendituresToDelete'
        );
        getExpendituresToDelete.returnValue = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Id = UnitTest.mockId(Schema.SObjectType.GAU_Expenditure__c)
            )
        };

        final UnitTest.Mock databaseService = new UnitTest.Mock();

        final UnitTest.Mock deleteRecords = databaseService.getMethod('deleteRecords');

        final UnitTest.Mock insertRecordsEnforceFls = databaseService.getMethod(
            'insertRecordsEnforceFls'
        );

        final UnitTest.Mock updateRecordsEnforceFls = databaseService.getMethod(
            'updateRecordsEnforceFls'
        );

        final UnitTest.Mock setSavepoint = databaseService.getMethod('setSavepoint');
        setSavepoint.returnValue = new DatabaseService.Savepoint();

        final UnitTest.Mock rollbackMethod = databaseService.getMethod('rollback');

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        GauExpendituresManager.databaseService = (DatabaseService) databaseService.createStub(
            DatabaseService.class
        );

        // Run the test.
        System.AuraHandledException actualException;

        GauExpendituresManager.upsertGauExpenditures(expendituresString, disbursementId);

        Test.stopTest();

        setSavepoint.assertCalledOnce();

        getExpendituresToDelete.assertCalledOnceWith(
            new List<Object>{
                disbursementId,
                new Set<Id>{ expectedExpendituresToUpdate[0].Id }
            }
        );

        deleteRecords.assertCalledOnceWith(
            new List<Object>{ getExpendituresToDelete.returnValue }
        );

        insertRecordsEnforceFls.assertCalledOnceWith(
            new List<Object>{ expectedExpendituresToInsert }
        );

        updateRecordsEnforceFls.assertCalledOnceWith(
            new List<Object>{ expectedExpendituresToUpdate }
        );

        rollbackMethod.assertNotCalled();
    }

    @IsTest
    private static void upsertGauExpenditures_ExceptionThrown() {
        // Set arguments, mock return values, and expected values.
        final Id disbursementId = UnitTest.mockId(
            Schema.SObjectType.outfunds__Disbursement__c
        );

        final List<GAU_Expenditure__c> expectedExpendituresToInsert = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Id = (Id) null,
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 0
            ),
            new GAU_Expenditure__c(
                Id = (Id) null,
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 2
            )
        };

        final List<GAU_Expenditure__c> expectedExpendituresToUpdate = new List<GAU_Expenditure__c>{
            new GAU_Expenditure__c(
                Id = UnitTest.mockId(Schema.SObjectType.GAU_Expenditure__c),
                Disbursement__c = disbursementId,
                General_Accounting_Unit__c = UnitTest.mockId(
                    Schema.SObjectType.npsp__General_Accounting_Unit__c
                ),
                Amount__c = 1
            )
        };

        List<GauExpendituresManager.GauExpenditureWrapper> expenditureWrappers = new List<GauExpendituresManager.GauExpenditureWrapper>();
        for (
            GAU_Expenditure__c expenditure : new List<GAU_Expenditure__c>{
                expectedExpendituresToInsert[0],
                expectedExpendituresToUpdate[0],
                expectedExpendituresToInsert[1]
            }
        ) {
            final GauExpendituresManager.GauExpenditureWrapper wrapper = new GauExpendituresManager.GauExpenditureWrapper();
            wrapper.recordId = expenditure.Id;
            wrapper.gauId = expenditure.General_Accounting_Unit__c;
            wrapper.amount = expenditure.Amount__c;

            expenditureWrappers.add(wrapper);
        }

        final String expendituresString = JSON.serialize(expenditureWrappers);

        // Set mocks.
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getExpendituresToDelete = gauExpenditureSelector.getMethod(
            'getExpendituresToDelete'
        );
        getExpendituresToDelete.returnValue = new UnitTest.TestException(
            'Query Exception'
        );

        final UnitTest.Mock databaseService = new UnitTest.Mock();

        final UnitTest.Mock deleteRecords = databaseService.getMethod('deleteRecords');

        final UnitTest.Mock insertRecordsEnforceFls = databaseService.getMethod(
            'insertRecordsEnforceFls'
        );

        final UnitTest.Mock updateRecordsEnforceFls = databaseService.getMethod(
            'updateRecordsEnforceFls'
        );

        final UnitTest.Mock setSavepoint = databaseService.getMethod('setSavepoint');
        setSavepoint.returnValue = new DatabaseService.Savepoint();

        final UnitTest.Mock rollbackMethod = databaseService.getMethod('rollback');

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        GauExpendituresManager.databaseService = (DatabaseService) databaseService.createStub(
            DatabaseService.class
        );

        // Run the test.
        System.AuraHandledException actualException;

        try {
            GauExpendituresManager.upsertGauExpenditures(
                expendituresString,
                disbursementId
            );
        } catch (System.AuraHandledException e) {
            actualException = e;
        }

        Test.stopTest();

        System.assertNotEquals(
            null,
            actualException,
            'getExpendituresToDelete should have thrown an Exception so upsertGauExpenditures should have re-thrown a System.AuraHandledException.'
        );
        System.assertEquals(
            'Query Exception',
            actualException.getMessage(),
            'getExpendituresToDelete should have thrown an Exception so upsertGauExpenditures should have re-thrown a System.AuraHandledException with the same message.'
        );

        setSavepoint.assertCalledOnce();

        getExpendituresToDelete.assertCalledOnceWith(
            new List<Object>{
                disbursementId,
                new Set<Id>{ expectedExpendituresToUpdate[0].Id }
            }
        );

        deleteRecords.assertNotCalled();

        insertRecordsEnforceFls.assertNotCalled();

        updateRecordsEnforceFls.assertNotCalled();

        rollbackMethod.assertCalledOnceWith(new List<Object>{ setSavepoint.returnValue });
    }

    @IsTest
    private static void searchActiveGeneralAccountingUnitsLikeName_QueryReturnsNoRecords() {
        // Set arguments, mock return values, and expected values.
        final String searchTerm = 'searchTerm';

        final List<GauExpendituresManager.LookupSearchResult> expected = new List<GauExpendituresManager.LookupSearchResult>();

        // Set mocks.
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getActiveGeneralAccountUnitsLikeName = gauExpenditureSelector.getMethod(
            'getActiveGeneralAccountUnitsLikeName'
        );
        getActiveGeneralAccountUnitsLikeName.returnValue = new List<npsp__General_Accounting_Unit__c>();

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        final List<GauExpendituresManager.LookupSearchResult> actual = GauExpendituresManager.searchActiveGeneralAccountingUnitsLikeName(
            searchTerm
        );

        Test.stopTest();

        GauExpendituresManager_TEST.assertEquals(expected, actual);

        getActiveGeneralAccountUnitsLikeName.assertCalledOnceWith(
            new List<Object>{ searchTerm }
        );
    }

    @IsTest
    private static void searchActiveGeneralAccountingUnitsLikeName_QueryReturnsRecords() {
        // Set arguments, mock return values, and expected values.
        final String searchTerm = 'searchTerm';

        final List<GauExpendituresManager.LookupSearchResult> expected = new List<GauExpendituresManager.LookupSearchResult>();
        for (Integer i = 0; i < 5; i++) {
            GauExpendituresManager.LookupSearchResult result = new GauExpendituresManager.LookupSearchResult();
            result.id = UnitTest.mockId(
                Schema.SObjectType.npsp__General_Accounting_Unit__c
            );
            result.sObjectType = Schema.SObjectType.npsp__General_Accounting_Unit__c.getName();
            result.icon = 'custom:custom87';
            result.title = 'Name ' + i;
            result.subtitle = 'Description ' + i;

            expected.add(result);
        }

        final List<npsp__General_Accounting_Unit__c> generalAccountingUnits = new List<npsp__General_Accounting_Unit__c>();
        for (GauExpendituresManager.LookupSearchResult result : expected) {
            generalAccountingUnits.add(
                new npsp__General_Accounting_Unit__c(
                    Id = result.Id,
                    Name = result.title,
                    npsp__Description__c = result.subtitle
                )
            );
        }

        // Set mocks.
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getActiveGeneralAccountUnitsLikeName = gauExpenditureSelector.getMethod(
            'getActiveGeneralAccountUnitsLikeName'
        );
        getActiveGeneralAccountUnitsLikeName.returnValue = generalAccountingUnits;

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        final List<GauExpendituresManager.LookupSearchResult> actual = GauExpendituresManager.searchActiveGeneralAccountingUnitsLikeName(
            searchTerm
        );

        Test.stopTest();

        GauExpendituresManager_TEST.assertEquals(expected, actual);

        getActiveGeneralAccountUnitsLikeName.assertCalledOnceWith(
            new List<Object>{ searchTerm }
        );
    }

    @IsTest
    private static void searchActiveGeneralAccountingUnitsLikeName_ThrowsException() {
        // Set arguments, mock return values, and expected values.
        final String searchTerm = 'searchTerm';

        // Set mocks.
        final UnitTest.Mock gauExpenditureSelector = new UnitTest.Mock();

        final UnitTest.Mock getActiveGeneralAccountUnitsLikeName = gauExpenditureSelector.getMethod(
            'getActiveGeneralAccountUnitsLikeName'
        );
        getActiveGeneralAccountUnitsLikeName.returnValue = new UnitTest.TestException(
            'Query Exception'
        );

        Test.startTest();

        // Set stubs.
        GauExpendituresManager.gauExpenditureSelector = (GauExpenditureSelector) gauExpenditureSelector.createStub(
            GauExpenditureSelector.class
        );

        // Run the test.
        System.AuraHandledException actualException;

        try {
            final List<GauExpendituresManager.LookupSearchResult> actual = GauExpendituresManager.searchActiveGeneralAccountingUnitsLikeName(
                searchTerm
            );
        } catch (System.AuraHandledException e) {
            actualException = e;
        }

        Test.stopTest();

        System.assertNotEquals(
            null,
            actualException,
            'getActiveGeneralAccountUnitsLikeName should have thrown an Exception so searchActiveGeneralAccountingUnitsLikeName should have re-thrown a System.AuraHandledException.'
        );
        System.assertEquals(
            'Query Exception',
            actualException.getMessage(),
            'getActiveGeneralAccountUnitsLikeName should have thrown an Exception so searchActiveGeneralAccountingUnitsLikeName should have re-thrown a System.AuraHandledException with the same message.'
        );

        getActiveGeneralAccountUnitsLikeName.assertCalledOnceWith(
            new List<Object>{ searchTerm }
        );
    }
}
