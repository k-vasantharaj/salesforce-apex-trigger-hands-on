trigger OpportunityTrigger on Opportunity (after insert) {
    HighestOpportunityValueOnAccountHandler.afterInsert();
}
//Handler
public class HighestOpportunityValueOnAccountHandler {

    /*
     * Updates Account with the highest Opportunity Amount
     * whenever a new Opportunity is inserted.
     */

    public static void afterInsert() {

        // Store highest Amount per Account from Trigger.new
        Map<Id, Decimal> accToNewMaxAmount = new Map<Id, Decimal>();

        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null && opp.Amount != null) {

                if (!accToNewMaxAmount.containsKey(opp.AccountId) ||
                    opp.Amount > accToNewMaxAmount.get(opp.AccountId)) {

                    accToNewMaxAmount.put(opp.AccountId, opp.Amount);
                }
            }
        }

        if (accToNewMaxAmount.isEmpty()) return;

        // Fetch existing Account values
        List<Account> accounts = [
            SELECT Id, Highest_Opportunity_Amount__c
            FROM Account
            WHERE Id IN :accToNewMaxAmount.keySet()
        ];

        List<Account> accToUpdate = new List<Account>();

        for (Account acc : accounts) {

            Decimal existingMax = acc.Highest_Opportunity_Amount__c == null
                ? 0
                : acc.Highest_Opportunity_Amount__c;

            Decimal newMax = Math.max(existingMax, accToNewMaxAmount.get(acc.Id));

            if (newMax != existingMax) {
                acc.Highest_Opportunity_Amount__c = newMax;
                accToUpdate.add(acc);
            }
        }

        if (!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
}
/*
Whenever a new Opportunity is created and associated with an Account,
the system should automatically compare the Opportunity’s Amount with the Account’s existing highest Opportunity value.
If the newly created Opportunity has a higher Amount, update the Account field Highest_Opportunity_Amount__c with the new maximum value.
*/
