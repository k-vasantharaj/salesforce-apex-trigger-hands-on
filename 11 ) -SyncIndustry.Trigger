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
