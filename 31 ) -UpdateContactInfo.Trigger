trigger ContactTrigger on Contact (before update) {

    /*
     * When a Contact’s Email OR Phone OR Title is updated,
     * update Account.Last_Contact_Update__c = System.today()
     * for the related Account.
     */

    Set<Id> accIds = new Set<Id>();

    for (Contact con : Trigger.new) {

        Contact oldContact = Trigger.oldMap.get(con.Id);

        if ((con.Email != oldContact.Email ||
             con.Phone != oldContact.Phone ||
             con.Title != oldContact.Title) &&
             con.AccountId != null) {

            accIds.add(con.AccountId);
        }
    }

    if (!accIds.isEmpty()) {

        List<Account> accList = new List<Account>();

        for (Account acc : [
            SELECT Id, Last_Contact_Update__c
            FROM Account
            WHERE Id IN :accIds
        ]) {
            acc.Last_Contact_Update__c = System.today();
            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}

//Test classs

@isTest
public class ContactTriggerTest {

    @isTest
    static void testAccountUpdatedWhenContactFieldChanges() {

        Account acc = new Account(Name = 'acc1');
        insert acc;

        Contact con = new Contact(
            LastName = 'con1',
            AccountId = acc.Id,
            Title = 'Old Title'
        );
        insert con;

        Test.startTest();
        con.Title = 'New Title';
        update con;
        Test.stopTest();

        Account updatedAcc = [
            SELECT Last_Contact_Update__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            System.today(),
            updatedAcc.Last_Contact_Update__c,
            'Account last contact update date should be set to today.'
        );
    }
}
