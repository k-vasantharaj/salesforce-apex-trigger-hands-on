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
