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
