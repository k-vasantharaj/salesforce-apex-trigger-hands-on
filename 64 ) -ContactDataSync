/*
Contact–Account Data Sync

When a Contact is inserted or updated:

If AccountId is present:
Copy Account.Industry → Contact.Industry__c
Copy Account.Phone → Contact.Account_Phone__c
If Account is changed, update the fields accordingly
Ensure logic works for bulk records
*/

//Trigger

trigger ContactAccountSyncTrigger on Contact (before insert, before update) 
{
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) 
    {   
        ContactAccountSyncHandler.syncAccountFieldsToContacts(Trigger.new);
    }
}

//Handler

public class ContactAccountSyncHandler 
{   
    public static void syncAccountFieldsToContacts(List<Contact> contacts){
        
        if(contacts.isEmpty()) return;
        
        Set<Id> accIds = new Set<Id>();
        
        for(Contact con : contacts)
        {
            if(con.AccountId != null)
            {
                accIds.add(con.AccountId);
            }
        }
        
        if(accIds.isEmpty()) return;
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Account acc : [SELECT Id, Industry, Phone 
                           FROM Account
                           WHERE Id IN :accIds])
        {
            accMap.put(acc.Id, acc);
        }
        
        for(Contact con : contacts)
        {
            if(con.AccountId != null && accMap.containsKey(con.AccountId))
            {
                Account acc = accMap.get(con.AccountId);
                
                con.Industry__c = acc.Industry;
                con.Account_Phone__c = acc.Phone;
            }
        }
    }
}

//Test class

@isTest
public class ContactAccountSyncHandlerTest {

    @isTest
    static void testInsertContacts() {
        
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            Industry = 'IT',
            Phone = '9876543210'
        );
        insert acc;
        
        // Create Contact
        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id
        );
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        // Fetch updated Contact
        Contact result = [SELECT Industry__c, Account_Phone__c 
                          FROM Contact 
                          WHERE Id = :con.Id];
        
        System.assertEquals('IT', result.Industry__c);
        System.assertEquals('9876543210', result.Account_Phone__c);
    }

    
    @isTest
    static void testUpdateContactAccountChange() {
        
        // Create Accounts
        Account acc1 = new Account(
            Name = 'Account 1',
            Industry = 'Finance',
            Phone = '1111111111'
        );
        
        Account acc2 = new Account(
            Name = 'Account 2',
            Industry = 'Healthcare',
            Phone = '2222222222'
        );
        
        insert new List<Account>{acc1, acc2};
        
        // Create Contact with acc1
        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = acc1.Id
        );
        insert con;
        
        // Change Account
        con.AccountId = acc2.Id;
        
        Test.startTest();
        update con;
        Test.stopTest();
        
        // Fetch updated Contact
        Contact result = [SELECT Industry__c, Account_Phone__c 
                          FROM Contact 
                          WHERE Id = :con.Id];
        
        System.assertEquals('Healthcare', result.Industry__c);
        System.assertEquals('2222222222', result.Account_Phone__c);
    }

    
    @isTest
    static void testBulkContacts() {
        
        // Create Account
        Account acc = new Account(
            Name = 'Bulk Account',
            Industry = 'Education',
            Phone = '9999999999'
        );
        insert acc;
        
        // Create multiple Contacts
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i = 0; i < 200; i++) {
            contactList.add(new Contact(
                LastName = 'Contact ' + i,
                AccountId = acc.Id
            ));
        }
        
        Test.startTest();
        insert contactList;
        Test.stopTest();
        
        // Verify
        List<Contact> results = [SELECT Industry__c, Account_Phone__c 
                                 FROM Contact 
                                 WHERE AccountId = :acc.Id];
        
        for(Contact c : results) {
            System.assertEquals('Education', c.Industry__c);
            System.assertEquals('9999999999', c.Account_Phone__c);
        }
    }
}
