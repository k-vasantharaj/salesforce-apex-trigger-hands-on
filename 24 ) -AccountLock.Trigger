trigger ContactTrigger on Contact (before update) {

    /*
     * QUESTION (Command-Line Style):
     * Q: How will you restrict updating AccountId for Contacts 
     *    once it is already associated with an Account?
     * A: By using a before update trigger and validating changes 
     *    using Trigger.oldMap. (Implementation below)
     */

    for (Contact con : Trigger.new) {
        Contact oldCon = Trigger.oldMap.get(con.Id);

        // Restrict changing AccountId once set
        if (oldCon.AccountId != null && con.AccountId != oldCon.AccountId) {
            con.addError('You cannot change the Account once it is set.');
        }
    }

}
/*
How can you prevent users from modifying AccountId on an existing Contact record?
*/

//Test class

@isTest
public class ContactAccountLockTriggerTest {

    // ---------- Helper method ----------
    private static Contact createContact() {
        Account a = new Account(Name = 'Acc1');
        insert a;

        Contact con = new Contact(
            Salutation = 'Mr',
            LastName = 'Vas',
            AccountId = a.Id
        );
        insert con;

        return con;
    }


    // ---------- Test 1 : should BLOCK account change ----------
    @isTest
    static void shouldPreventAccountChange() {

        Contact con = createContact();

        Account newAcc = new Account(Name = 'Acc2');
        insert newAcc;

        Boolean errorThrown = false;

        Test.startTest();
        try {
            con.AccountId = newAcc.Id;
            update con;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(
            true,
            errorThrown,
            'Account change must be blocked'
        );
    }


    // ---------- Test 2 : should ALLOW normal field update ----------
    @isTest
    static void shouldAllowOtherFieldUpdate() {

        Contact con = createContact();

        Boolean errorThrown = false;

        Test.startTest();
        try {
            con.LastName = 'Vasa';
            update con;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(
            false,
            errorThrown,
            'Normal updates should be allowed'
        );
    }
}
