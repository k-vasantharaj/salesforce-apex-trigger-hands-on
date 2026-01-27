trigger OpportunityTrigger on Opportunity (before insert, before update) {

    Set<String> accountNames = new Set<String>();

    for (Opportunity opp : Trigger.new) {
        if (opp.AccountName__c != null) {
            accountNames.add(opp.AccountName__c.trim().toLowerCase());
        }
    }

    if (accountNames.isEmpty()) return;

    Map<String, Id> accountNameToIdMap = new Map<String, Id>();

    for (Account acc : [
        SELECT Id, Name
        FROM Account
        WHERE Name IN :accountNames
    ]) {
        accountNameToIdMap.put(acc.Name.toLowerCase(), acc.Id);
    }

    for (Opportunity opp : Trigger.new) {
        if (
            opp.AccountName__c != null &&
            accountNameToIdMap.containsKey(opp.AccountName__c.trim().toLowerCase())
        )
        {
            opp.AccountId = accountNameToIdMap.get(
                opp.AccountName__c.trim().toLowerCase()
            );
        }
    }
}

/*
When inserting an Opportunity, if a custom text field AccountName__c contains the name of an existing Account, 
automatically populate the AccountId lookup field with that Account’s Id.
*/


//Test class

@isTest
public class asyncDemo {

    @isTest
    static void opportunity() {

        Account acc = new Account();
        acc.Name = 'vas_' + System.currentTimeMillis(); // 🔧 make name unique
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'opp1';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today().addDays(30);
        opp.AccountName__c = acc.Name; // 🔧 use same name
        insert opp;

        List<Opportunity> oppList = [
            SELECT AccountId, Name, AccountName__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ]; // 🔧 query by Id (reliable)

        System.assertEquals(
            acc.Id,
            oppList[0].AccountId,
            'opp AccountId and acc Id must be equal'
        );

        System.assertEquals(
            acc.Name,
            oppList[0].AccountName__c,
            'AccountName__c must match Account Name'
        );
    }
}
