/*
Whenever a Contact is inserted or updated, implement the following logic:

If the Email field is empty, automatically copy the Account’s Email_Domain__c into the Contact’s Email_Domain__c field.
*/


//Trigger
trigger ContactTrigger on Contact (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        TriggerHandler.updateEmailDomain(Trigger.new);
    }

}

//TriggerHandler


public class TriggerHandler {

    /*
    Whenever a Contact is inserted or updated:
    If the Email field is empty, copy the Account's Email_Domain__c
    into the Contact's Email_Domain__c field.
    */

    public static void updateEmailDomain(List<Contact> contacts){

        if(contacts == null || contacts.isEmpty()){
            return;
        }

        Set<Id> accountIds = new Set<Id>();

        for(Contact con : contacts){
            if(con.AccountId != null && con.Email == null){
                accountIds.add(con.AccountId);
            }
        }

        if(accountIds.isEmpty()){
            return;
        }

        Map<Id, String> accMap = new Map<Id, String>();

        for(Account acc : [
            SELECT Id, Email_Domain__c
            FROM Account
            WHERE Id IN :accountIds
            AND Email_Domain__c != null
        ]){
            accMap.put(acc.Id, acc.Email_Domain__c);
        }

        for(Contact con : contacts){
            if(con.AccountId != null && con.Email == null){
                if(accMap.containsKey(con.AccountId)){
                    con.Email_Domain__c = accMap.get(con.AccountId);
                }
            }
        }
    }
}
