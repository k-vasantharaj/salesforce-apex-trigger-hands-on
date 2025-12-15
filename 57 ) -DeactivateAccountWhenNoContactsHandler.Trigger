trigger ContactTrigger on Contact (after delete) {
    DeactivateAccountWhenNoContactsHandler.run();
}
public class DeactivateAccountWhenNoContactsHandler {

    /*
     * Deactivates an Account when its last Contact is deleted
     */

    public static void run() {
        if (Trigger.isAfter && Trigger.isDelete) {
            afterDelete();
        }
    }

    private static void afterDelete() {

        // Collect Account Ids from deleted Contacts
        Set<Id> accIds = new Set<Id>();

        for (Contact con : Trigger.old) {
            if (con.AccountId != null) {
                accIds.add(con.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        // Count remaining Contacts per Account
        Map<Id, Integer> accToContactCount = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            accToContactCount.put(
                (Id) ar.get('accId'),
                (Integer) ar.get('contactCount')
            );
        }

        List<Account> accToUpdate = new List<Account>();

        // Fetch only ACTIVE Accounts
        for (Account acc : [
            SELECT Id, Active__c
            FROM Account
            WHERE Id IN :accIds
            AND Active__c = true
        ]) {

            Integer remainingContacts =
                accToContactCount.containsKey(acc.Id)
                ? accToContactCount.get(acc.Id)
                : 0;

            if (remainingContacts == 0) {
                acc.Active__c = false;
                accToUpdate.add(acc);
            }
        }

        if (!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
    }
}
/*
Whenever a Contact record is deleted, the system should automatically check the related Account.
If the Account has no remaining Contacts and the Account is currently Active,
the system must deactivate the Account by setting the field Active__c to false.
*/
