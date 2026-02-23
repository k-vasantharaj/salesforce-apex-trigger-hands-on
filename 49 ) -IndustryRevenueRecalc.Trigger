/*
Whenever an Account’s Industry field is updated, 
recalculate the Total_Revenue__c field by summing the Amount of all related Opportunities, 
using AggregateResult in an after update Apex trigger.
*/
//Trigger

trigger AccountTrigger on Account (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        TriggerHandler.updatingTotal_Revenue(Trigger.new, Trigger.oldMap);
    }

}

//Handler

public class TriggerHandler {

    public static void updatingTotal_Revenue(List<Account> newList,
                                              Map<Id, Account> oldMap) {

        Set<Id> accountIds = new Set<Id>();

        // Step 1 – collect only accounts whose Industry changed
        for (Account acc : newList) {

            Account oldAcc = oldMap.get(acc.Id);

            if (oldAcc != null && oldAcc.Industry != acc.Industry) {
                accountIds.add(acc.Id);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Step 2 – aggregate opportunity amounts
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

        // Step 3 – prepare accounts to update
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {

            Decimal totalRevenue = accountToRevenue.containsKey(accId)
                ? accountToRevenue.get(accId)
                : 0;

            accountsToUpdate.add(new Account(
                Id = accId,
                Total_Revenue__c = totalRevenue
            ));
        }

        // Step 4 – update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}


