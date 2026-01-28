trigger contactTrigger on Contact (before insert, before update) {

    /*
      Prevent Contact creation when the related Account is inactive.
    */

    Set<Id> accIds = new Set<Id>();

    for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
            accIds.add(con.AccountId);
        }
    }

    if (accIds.isEmpty()) return;

    Set<Id> inactiveAccIds = new Set<Id>();

    for (Account acc : [
        SELECT Id, Active__c
        FROM Account
        WHERE Active__c = false
        AND Id IN :accIds
    ]) {
        inactiveAccIds.add(acc.Id);
    }

    for (Contact con : Trigger.new) {
        if (con.AccountId != null && inactiveAccIds.contains(con.AccountId)) {
            con.addError('Account cannot be inactive');
        }
    }
}

/*
 Prevent Contact creation when the related Account is inactive.
*/
