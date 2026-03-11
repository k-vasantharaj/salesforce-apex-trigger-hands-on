/*
When a Contact is inserted, if the Contact Phone is empty, 
copy the Phone from the related Account to the Contact. 
The solution should work only when an Account exists and must be bulk-safe.
*/

//Trigger

trigger ContactTrigger on Contact (before insert) 
{
    if (Trigger.isBefore && Trigger.isInsert) 
    {   
        TriggerHandler.CopyingAccountPhone(Trigger.new);
    }
    
}

//TriggerHandler

public class TriggerHandler 
{   
    /*
    Contact Phone from Account
    Whenever a Contact is inserted, if the Phone field is empty, copy the Account Phone to the Contact.
    Requirement
    Works only if Account exists
    Must be bulk safe
    */
      
    public static void CopyingAccountPhone(List<Contact> newContacts){
        
        if(newContacts.isEmpty()) return;
        
        Set<Id> accountIds = new Set<Id>();
        
        for(Contact con : newContacts)
        {
            if(con.AccountId != null && con.Phone == null)
            {
                accountIds.add(con.AccountId);
            }
        }
        
        Map<Id,String> accMap = new Map<Id,String>();
        
        for(Account acc : [SELECT Id, Phone 
                           FROM Account
                           WHERE Id IN :accountIds
                           AND Phone != null])
        {
            accMap.put(acc.Id, acc.Phone);
        }
        
        for(Contact con : newContacts)
        {
            if(con.AccountId != null && con.Phone == null && accMap.containsKey(con.AccountId))
            {
                con.Phone = accMap.get(con.AccountId);
            }
        }
    }
}
