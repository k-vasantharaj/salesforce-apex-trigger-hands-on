trigger OpportunityTrigger on Opportunity (before update) {

    // Step 1: Collect AccountIds that are being changed
    Set<Id> changedAccountIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if (opp.AccountId != oldOpp.AccountId && opp.AccountId != null) {
            changedAccountIds.add(opp.AccountId);
        }
    }

    // Step 2: Query Accounts that are NOT approved
    Map<Id, Boolean> accountApprovalMap = new Map<Id, Boolean>();
    if (!changedAccountIds.isEmpty()) {
        for (Account acc : [
            SELECT Id, Is_Approved__c
            FROM Account
            WHERE Id IN :changedAccountIds
        ]) {
            accountApprovalMap.put(acc.Id, acc.Is_Approved__c);
        }
    }

    // Step 3: Block Opportunity update if new Account is not approved
    for (Opportunity opp : Trigger.new) {
        if (opp.AccountId != null &&
            accountApprovalMap.containsKey(opp.AccountId) &&
            accountApprovalMap.get(opp.AccountId) == false) {
            
            opp.addError('Account change blocked: The selected Account is not approved.');
        }
    }
}


    /*
How can you prevent an Opportunity from being reassigned to an Account that is not approved when the AccountId is changed during an update?
     */

