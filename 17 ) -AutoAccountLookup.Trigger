trigger OpportunityTrigger on Opportunity (before insert, before update) {

    Set<String> accountNames = new Set<String>();

    for (Opportunity opp : Trigger.new) {
        if (opp.AccountName__c != null) {
            accountNames.add(opp.AccountName__c.trim().toLowerCase());
        }
    }

    if (accountNames.isEmpty()) return;

    Map<String, Id> accountNameToIdMap = new Map<String, Id>();

    for (Account acc : [
        SELECT Id, Name
        FROM Account
        WHERE Name IN :accountNames
    ]) {
        accountNameToIdMap.put(acc.Name.toLowerCase(), acc.Id);
    }

    for (Opportunity opp : Trigger.new) {
        if (
            opp.AccountName__c != null &&
            accountNameToIdMap.containsKey(opp.AccountName__c.trim().toLowerCase())
        )
        {
            opp.AccountId = accountNameToIdMap.get(
                opp.AccountName__c.trim().toLowerCase()
            );
        }
    }
}

/*
When inserting an Opportunity, if a custom text field AccountName__c contains the name of an existing Account, 
automatically populate the AccountId lookup field with that Account’s Id.
*/
