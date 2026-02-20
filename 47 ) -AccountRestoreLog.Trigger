trigger AccountTrigger on Account (after undelete) {

    /*
     * Requirement:
     * When an Account is undeleted, insert a new Account_History__c record
     * with Status__c = 'Restored' and basic log details.
     */

    List<Account_History__c> historyList = new List<Account_History__c>();

    for (Account acc : Trigger.new) {

        Account_History__c log = new Account_History__c();
        log.Account__c = acc.Id;              // Link to Account (important)
        log.Name = acc.Name + ' - Restored'; // Optional meaningful name
        log.Status__c = 'Restored';
        log.Action_Date__c = System.today();
        log.Changed_By__c = UserInfo.getUserId(); // More accurate than OwnerId

        historyList.add(log);
    }

    if (!historyList.isEmpty()) {
        insert historyList;
    }
}
/*
When an Account record is undeleted from the Recycle Bin, 
the system must automatically create a new log entry in the custom object Account_History__c. 
This entry should record that the Account was restored by setting Status__c = 'Restored', 
along with basic details like name, date, and user.
*/

//Test class

@IsTest
public class AccountRestoreHistoryTest {

    @IsTest
    static void testAccountHistoryCreatedOnUndelete() {

        // Create Account
        Account acc = new Account(Name = 'Test Restore');
        insert acc;

        // Delete the Account
        delete acc;

        // Undelete (this must fire your logic)
        Test.startTest();
        undelete acc;
        Test.stopTest();

        // Verify history record
        List<Account_History__c> historyList = [
            SELECT Account__c,
                   Name,
                   Status__c,
                   Action_Date__c,
                   Changed_By__c
            FROM Account_History__c
            WHERE Account__c = :acc.Id
        ];

        // Assert one history record created
        System.assertEquals(1, historyList.size());

        Account_History__c log = historyList[0];

        System.assertEquals(acc.Id, log.Account__c);
        System.assertEquals(acc.Name + ' - Restored', log.Name);
        System.assertEquals('Restored', log.Status__c);
        System.assertEquals(System.today(), log.Action_Date__c);
        System.assertEquals(UserInfo.getUserId(), log.Changed_By__c);
    }
}
