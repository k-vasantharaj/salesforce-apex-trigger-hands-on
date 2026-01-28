trigger contactTrigger on Contact (before insert, before update) {

    /*
      Prevent Contact creation when the related Account is inactive.
    */

    Set<Id> accIds = new Set<Id>();

    for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
            accIds.add(con.AccountId);
        }
    }

    if (accIds.isEmpty()) return;

    Set<Id> inactiveAccIds = new Set<Id>();

    for (Account acc : [
        SELECT Id, Active__c
        FROM Account
        WHERE Active__c = false
        AND Id IN :accIds
    ]) {
        inactiveAccIds.add(acc.Id);
    }

    for (Contact con : Trigger.new) {
        if (con.AccountId != null && inactiveAccIds.contains(con.AccountId)) {
            con.addError('Account cannot be inactive');
        }
    }
}

/*
 Prevent Contact creation when the related Account is inactive.
*/


//Test class

@isTest
public class asyncDemo {

    // ✅ Positive case: Active account → Contact should be created
    @isTest
    static void opportunity_activeAccount() {

        Account acc = new Account();
        acc.Name = 'vas_active_' + System.currentTimeMillis();
        acc.Active__c = 'TRUE';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'con1';
        con.AccountId = acc.Id;
        insert con;

        List<Contact> conList = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :acc.Id
        ];

        System.assertEquals(
            1,
            conList.size(),
            'Contact must be created for active account'
        );
    }

    // ❌ Negative case: Inactive account → Contact creation must be blocked
    @isTest
    static void opportunity_inactiveAccount() {

        Account acc = new Account();
        acc.Name = 'vas_inactive_' + System.currentTimeMillis();
        acc.Active__c = 'FALSE';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'con1';
        con.AccountId = acc.Id;

        Boolean errorThrown = false;

        try {
            insert con; // expected to fail due to trigger
        } catch (DmlException e) {
            errorThrown = true;
        }

        System.assertEquals(
            true,
            errorThrown,
            'Contact must not be created for inactive account'
        );
    }
}

