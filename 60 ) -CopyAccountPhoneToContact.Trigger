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


//Test class

@isTest
public class ContactPhoneFromAccountTest {

    @isTest
    static void testPhoneCopiedFromAccount() {

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '808098098'
        );
        insert testAccount;

        // Create Contact without Phone
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify Phone copied from Account
        Contact resultContact = [
            SELECT Phone
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals(
            '808098098',
            resultContact.Phone,
            'Contact phone should be copied from Account'
        );
    }

    @isTest
    static void testPhoneNotOverwrittenIfAlreadyExists() {

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '808098098'
        );
        insert testAccount;

        // Create Contact with existing Phone
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Phone = '098098098',
            AccountId = testAccount.Id
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify Phone is not overwritten
        Contact resultContact = [
            SELECT Phone
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals(
            '098098098',
            resultContact.Phone,
            'Existing contact phone should not be overwritten'
        );
    }
}
