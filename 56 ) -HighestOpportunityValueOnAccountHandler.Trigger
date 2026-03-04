/*
Whenever a new Opportunity is created and associated with an Account,
the system should automatically compare the Opportunity’s Amount with the Account’s existing highest Opportunity value.
If the newly created Opportunity has a higher Amount, update the Account field Highest_Opportunity_Amount__c with the new maximum value.
*/

//Trigger
trigger OpportunityTrigger on Opportunity (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.updateAccountHighestOpportunityAmount(Trigger.new);
    }

}

//TriggerHandler
public class OpportunityTriggerHandler {

    /*
    Whenever a new Opportunity is created and associated with an Account,
    compare the Opportunity Amount with the Account’s current highest Opportunity value.
    If the new Opportunity has a higher Amount, update
    Account.Highest_Opportunity_Amount__c.
    */

    public static void updateAccountHighestOpportunityAmount(List<Opportunity> newOpportunities) {

        if (newOpportunities.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();

        for (Opportunity opp : newOpportunities) {
            if (opp.AccountId != null && opp.Amount != null) {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Decimal> accountHighestAmountMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId accId, MAX(Amount) maxAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountHighestAmountMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('maxAmount')
            );
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.Highest_Opportunity_Amount__c =
                accountHighestAmountMap.containsKey(accId)
                ? accountHighestAmountMap.get(accId)
                : 0;

            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}


