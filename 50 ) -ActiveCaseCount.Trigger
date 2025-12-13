trigger AccountTrigger on Account (after update) {

    /*
     * Requirement:
     * Account has a custom field Active_Case_Count__c.
     * This should reflect the number of related Cases with Status != 'Closed'.
     */

    // Step 1: Collect Account IDs for processing
    Set<Id> accountIds = new Set<Id>();

    for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        // Optional: Detect specific field changes; 
        // here we process all updates for simplicity
        accountIds.add(acc.Id);
    }

    if (accountIds.isEmpty()) return;

    // Step 2: Aggregate Cases by Account
    Map<Id, Integer> caseCountMap = new Map<Id, Integer>();

    for (AggregateResult ar : [
        SELECT AccountId accId, COUNT(Id) statusCount
        FROM Case
        WHERE AccountId IN :accountIds
          AND Status != 'Closed'
        GROUP BY AccountId
    ]) {
        caseCountMap.put(
            (Id) ar.get('accId'),
            (Integer) ar.get('statusCount')
        );
    }

    // Step 3: Prepare Account records for update
    List<Account> accountsToUpdate = new List<Account>();

    for (Id accId : accountIds) {
        accountsToUpdate.add(new Account(
            Id = accId,
            Active_Case_Count__c = caseCountMap.containsKey(accId) 
                ? caseCountMap.get(accId) 
                : 0
        ));
    }

    // Step 4: Update Accounts
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
/*
Write a bulkified after-update Apex trigger on Account that updates a custom field Active_Case_Count__c.
This field should store the number of related Case records where Status ≠ 'Closed'.
*/
