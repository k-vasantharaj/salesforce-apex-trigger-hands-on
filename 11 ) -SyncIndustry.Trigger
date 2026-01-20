trigger accountTrigger on Account (after update) {

    Set<Id> changedAccIds = new Set<Id>();

    // Step 1: Find Accounts where Industry changed
    for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);
        if (acc.Industry != oldAcc.Industry) {
            changedAccIds.add(acc.Id);
        }
    }

    if (!changedAccIds.isEmpty()) {

        // Step 2: Query all related contacts in bulk
        List<Contact> contactsToUpdate = [SELECT Id, Industry__c, AccountId
                                          FROM Contact
                                          WHERE AccountId IN :changedAccIds];

        // Step 3: Update Industry__c for all contacts
        for (Contact con : contactsToUpdate) {
            Account parentAcc = Trigger.newMap.get(con.AccountId);
            con.Industry__c = parentAcc.Industry;
        }

        // Step 4: Bulk update contacts
        update contactsToUpdate;
    }
}
/*
When the Industry field on an Account is updated,
automatically update the related Contacts’ custom field Industry__c to match the updated Account Industry.
*/

//Test class
@IsTest
public class AccountTriggerSpec {

    @IsTest
    static void shouldUpdateContactIndustryWhenAccountIndustryChanges() {

        // Arrange
        Account acc = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert acc;

        Contact con1 = new Contact(
            LastName = 'Contact One',
            AccountId = acc.Id
        );
        Contact con2 = new Contact(
            LastName = 'Contact Two',
            AccountId = acc.Id
        );
        insert new List<Contact>{ con1, con2 };

        // Act
        acc.Industry = 'Healthcare';
        update acc;

        // Assert
        List<Contact> updatedContacts = [
            SELECT Industry__c
            FROM Contact
            WHERE AccountId = :acc.Id
        ];

        System.assertEquals(
            2,
            updatedContacts.size(),
            'All related contacts should be updated'
        );

        for (Contact con : updatedContacts) {
            System.assertEquals(
                'Healthcare',
                con.Industry__c,
                'Contact Industry__c should match Account Industry'
            );
        }
    }
}
