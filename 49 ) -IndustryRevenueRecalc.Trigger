trigger AccountTrigger on Account (after update) {

    // Step 1: Collect Accounts whose Industry changed
    Set<Id> accountIds = new Set<Id>();

    for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);
        if (oldAcc.Industry != acc.Industry) {
            accountIds.add(acc.Id);
        }
    }

    if (accountIds.isEmpty()) return;

    // Step 2: Aggregate Opportunity Amounts
    Map<Id, Decimal> accountToRevenue = new Map<Id, Decimal>();

    for (AggregateResult ar : [
        SELECT AccountId accId, SUM(Amount) totalAmount
        FROM Opportunity
        WHERE AccountId IN :accountIds
        GROUP BY AccountId
    ]) {
        accountToRevenue.put(
            (Id) ar.get('accId'),
            (Decimal) ar.get('totalAmount')
        );
    }

    // Step 3: Update Accounts
    List<Account> accountsToUpdate = new List<Account>();

    for (Id accId : accountIds) {
        accountsToUpdate.add(new Account(
            Id = accId,
            Total_Revenue__c = accountToRevenue.containsKey(accId)
                ? accountToRevenue.get(accId)
                : 0
        ));
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
/*
Whenever an Account’s Industry field is updated, 
recalculate the Total_Revenue__c field by summing the Amount of all related Opportunities, 
using AggregateResult in an after update Apex trigger.
*/
