trigger OpportunityTrigger on Opportunity (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        Set<String> accNames = new Set<String>();

        // Collect names from incoming Opportunities
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountName__c != null) {
                accNames.add(opp.AccountName__c.trim());
            }
        }

        if (!accNames.isEmpty()) {

            // Query only the required Accounts (bulk safe)
            Map<String, Id> accMap = new Map<String, Id>();
            for (Account acc : [
                SELECT Id, Name
                FROM Account
                WHERE Name IN :accNames
            ]) {
                accMap.put(acc.Name, acc.Id);
            }

            // Populate Account lookup
            for (Opportunity opp : Trigger.new) {

                if (opp.AccountName__c != null) {
                    Id accId = accMap.get(opp.AccountName__c.trim());

                    if (accId != null) {
                        opp.AccountId = accId;
                    }
                    // Missing matches handled gracefully
                }
            }
        }
    }
}
