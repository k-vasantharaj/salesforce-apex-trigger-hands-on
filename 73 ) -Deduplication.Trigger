//Question 
Prevent Account creation if another Account exists with same Name and Phone.

//Trigger
trigger AccountTrigger on Account (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AccountTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}

//Handler

public class AccountTriggerHandler {

    public static void handleBeforeInsert(List<Account> newAccounts) {

        if (newAccounts == null || newAccounts.isEmpty()) {
            return;
        }

        Set<String> compositeKeys = new Set<String>();
        Map<String, Account> existingAccountMap = new Map<String, Account>();

        // Collect keys from incoming records
        for (Account acc : newAccounts) {
            if (acc.Name != null && acc.Phone != null) {
                String key = acc.Name.trim().toLowerCase() + '|' + acc.Phone.trim();
                compositeKeys.add(key);
            }
        }

        // Query only relevant existing accounts (bulk-safe)
        for (Account acc : [
            SELECT Id, Name, Phone
            FROM Account
            WHERE Name != null AND Phone != null
        ]) {
            String key = acc.Name.trim().toLowerCase() + '|' + acc.Phone.trim();
            if (compositeKeys.contains(key)) {
                existingAccountMap.put(key, acc);
            }
        }

        // Validate duplicates
        for (Account acc : newAccounts) {
            if (acc.Name != null && acc.Phone != null) {
                String key = acc.Name.trim().toLowerCase() + '|' + acc.Phone.trim();

                if (existingAccountMap.containsKey(key)) {
                    acc.addError('Duplicate Account with same Name and Phone exists.');
                }
            }
        }
    }
}

//Testclass

@isTest
public class AccountTriggerHandlerTest {

    @isTest
    static void testDuplicatePrevention() {

        // Create an existing account
        Account existing = new Account(
            Name = 'Test Company',
            Phone = '1234567890'
        );
        insert existing;

        // Attempt duplicate insert
        Account duplicate = new Account(
            Name = 'Test Company',
            Phone = '1234567890'
        );

        Test.startTest();
        try {
            insert duplicate;
            System.assert(false, 'Expected duplicate error not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Duplicate Account'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNonDuplicateInsert() {

        Account acc1 = new Account(
            Name = 'Company A',
            Phone = '1111111111'
        );

        Account acc2 = new Account(
            Name = 'Company B',
            Phone = '2222222222'
        );

        Test.startTest();
        insert new List<Account>{acc1, acc2};
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Account]);
    }
}

