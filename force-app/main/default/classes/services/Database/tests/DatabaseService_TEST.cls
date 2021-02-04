@isTest
public with sharing class DatabaseService_TEST {
    @isTest
    private static void test() {
        try {
            if (true) {
                Exception e = new System.NoAccessException();
                e.setMessage(System.Label.DatabaseService_NoDeleteAccessException);
                throw e;
            }
        } catch (Exception e) {
            System.assert(false, e.getMessage());
        }
    }
}
