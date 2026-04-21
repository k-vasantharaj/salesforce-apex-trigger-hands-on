//Question
//Write a trigger to update a custom field Total_Contacts__c on Account whenever Contacts are inserted, updated, or deleted.

//Trigger

trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) 
{
    if(Trigger.isAfter && Trigger.isInsert)
    {
        TriggerHandler.afterInsertOperation(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        TriggerHandler.afterUpdateOperation(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isDelete)
    {
        TriggerHandler.beforeDeleteOperation(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isUndelete)
    {
        TriggerHandler.beforeUndeleteOperation(Trigger.new);
    }
}

//Handler
public class TriggerHandler {

   

    public static void afterInsertOperation(List<Contact> insertedContacts) {
        if(insertedContacts == null || insertedContacts.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();

        for(Contact con : insertedContacts) {
            if(con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Decimal> accMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) conCounts
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('conCounts')
            );
        }

        List<Account> accToUpdate = new List<Account>();

        for(Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.count_of_contacts__c = accMap.containsKey(accId) ? accMap.get(accId) : 0;
            accToUpdate.add(acc);
        }

        if(!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }

    public static void afterUpdateOperation(List<Contact> updatedContacts) {
        if(updatedContacts == null || updatedContacts.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();

        for(Contact con : updatedContacts) {
            if(con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Decimal> accMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) conCounts
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('conCounts')
            );
        }

        List<Account> accToUpdate = new List<Account>();

        for(Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.count_of_contacts__c = accMap.containsKey(accId) ? accMap.get(accId) : 0;
            accToUpdate.add(acc);
        }

        if(!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }

    public static void afterDeleteOperation(List<Contact> deletedContacts) {
        if(deletedContacts == null || deletedContacts.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();

        for(Contact con : deletedContacts) {
            if(con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Decimal> accMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) conCounts
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('conCounts')
            );
        }

        List<Account> accToUpdate = new List<Account>();

        for(Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.count_of_contacts__c = accMap.containsKey(accId) ? accMap.get(accId) : 0;
            accToUpdate.add(acc);
        }

        if(!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }

    public static void afterUndeleteOperation(List<Contact> undeletedContacts) {
        if(undeletedContacts == null || undeletedContacts.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();

        for(Contact con : undeletedContacts) {
            if(con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Decimal> accMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) conCounts
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('conCounts')
            );
        }

        List<Account> accToUpdate = new List<Account>();

        for(Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.count_of_contacts__c = accMap.containsKey(accId) ? accMap.get(accId) : 0;
            accToUpdate.add(acc);
        }

        if(!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
}


//Test class

@isTest
public class ContactTriggerTest {

    @isTest
    static void testInsertContacts() {

        Account acc = new Account(Name = 'TestAcc');
        insert acc;

        Test.startTest();

        List<Contact> cons = new List<Contact>{
            new Contact(LastName = 'A', AccountId = acc.Id),
            new Contact(LastName = 'B', AccountId = acc.Id)
        };
        insert cons;

        Test.stopTest();

        Account updated = [
            SELECT count_of_contacts__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(2, updated.count_of_contacts__c,
            'Count should be 2 after insert');
    }

    @isTest
    static void testDeleteContacts() {

        Account acc = new Account(Name = 'TestAcc2');
        insert acc;

        List<Contact> cons = new List<Contact>{
            new Contact(LastName = 'A', AccountId = acc.Id),
            new Contact(LastName = 'B', AccountId = acc.Id)
        };
        insert cons;

        Test.startTest();
        delete cons[0];
        Test.stopTest();

        Account updated = [
            SELECT count_of_contacts__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(1, updated.count_of_contacts__c,
            'Count should reduce after delete');
    }

    @isTest
    static void testUndeleteContacts() {

        Account acc = new Account(Name = 'TestAcc3');
        insert acc;

        Contact con = new Contact(LastName = 'A', AccountId = acc.Id);
        insert con;

        delete con;

        Test.startTest();
        undelete con;
        Test.stopTest();

        Account updated = [
            SELECT count_of_contacts__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(1, updated.count_of_contacts__c,
            'Count should restore after undelete');
    }

    @isTest
    static void testUpdateAccountChange() {

        Account acc1 = new Account(Name = 'Acc1');
        Account acc2 = new Account(Name = 'Acc2');
        insert new List<Account>{acc1, acc2};

        Contact con = new Contact(LastName = 'Test', AccountId = acc1.Id);
        insert con;

        Test.startTest();
        con.AccountId = acc2.Id;
        update con;
        Test.stopTest();

        Account updated1 = [
            SELECT count_of_contacts__c FROM Account WHERE Id = :acc1.Id
        ];

        Account updated2 = [
            SELECT count_of_contacts__c FROM Account WHERE Id = :acc2.Id
        ];

        // This will FAIL with your current logic → and that's correct
        System.assertEquals(0, updated1.count_of_contacts__c,
            'Old account should reduce count');

        System.assertEquals(1, updated2.count_of_contacts__c,
            'New account should increase count');
    }
}
