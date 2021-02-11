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
        GauExpendituresManager.GauExpenditureWrapper expected,
        GauExpendituresManager.GauExpenditureWrapper actual
    ) {
        GauExpendituresManager_TEST.assertEquals(expected, actual, (Integer) null);
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

            if (expected.expenditures == null) {
                System.assertEquals(
                    null,
                    actual.expenditures,
                    'DisbursementWrapper.expenditures'
                );
            } else {
                System.assertNotEquals(
                    null,
                    actual.expenditures,
                    'DisbursementWrapper.expenditures'
                );

                final Integer expendituresSize = expected.expenditures.size();
                System.assertEquals(
                    expendituresSize,
                    actual.expenditures.size(),
                    'DisbursementWrapper.expenditures.size()'
                );

                for (Integer i = 0; i < expendituresSize; i++) {
                    GauExpendituresManager_TEST.assertEquals(
                        expected.expenditures[i],
                        actual.expenditures[i],
                        i
                    );
                }
            }
        }
    }

    public static void assertEquals(
        GauExpendituresManager.LookupSearchResult expected,
        GauExpendituresManager.LookupSearchResult actual
    ) {
        if (expected == null) {
            System.assertEquals(null, actual);
        } else {
            System.assertNotEquals(null, actual);

            System.assertEquals(expected.id, actual.id, 'LookupSearchResult.id');
            System.assertEquals(
                expected.sObjectType,
                actual.sObjectType,
                'LookupSearchResult.sObjectType'
            );
            System.assertEquals(expected.icon, actual.icon, 'LookupSearchResult.icon');
            System.assertEquals(expected.title, actual.title, 'LookupSearchResult.title');
            System.assertEquals(
                expected.subtitle,
                actual.subtitle,
                'LookupSearchResult.subtitle'
            );
        }
    }

    @IsTest
    private static void GauExpenditureWrapper_NonNullGauId() {
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
                            '"type": "GAU_Expenditure__c",',
                            '"url": "/services/data/v51.0/sobjects/GAU_Expenditure__c/a0x9A000000ASvfQAG"',
                        '},',
                        '"Disbursement__c": "a0s9A000000cuCSQAY",',
                        '"Id": "' + recordId + '",',
                        '"General_Accounting_Unit__c": "' + gauId + '",',
                        '"Amount__c": ' + amount.toPlainString() + ',',
                        '"General_Accounting_Unit__r": {',
                            '"attributes": {',
                                '"type": "npsp__General_Accounting_Unit__c",',
                                '"url": "/services/data/v51.0/sobjects/npsp__General_Accounting_Unit__c/a0d9A0000003r1sQAA"',
                            '},',
                            '"Id": "a0d9A0000003r1sQAA",',
                            '"Name": "Area of most need",',
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
}
