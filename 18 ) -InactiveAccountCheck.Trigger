trigger contactTrigger on Contact (before insert) {

    Set<Id> accountIds = new Set<Id>();

    for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
            accountIds.add(con.AccountId);
        }
    }

    // Fetch only inactive accounts
    Map<Id, Account> inactiveAccounts = new Map<Id, Account>(
        [SELECT Id FROM Account WHERE Id IN :accountIds AND Active__c = 'False']
    );

    for (Contact con : Trigger.new) {
        if (con.AccountId != null && inactiveAccounts.containsKey(con.AccountId)) {
            con.addError('Cannot create Contact because the related Account is inactive.');
        }
    }
}
