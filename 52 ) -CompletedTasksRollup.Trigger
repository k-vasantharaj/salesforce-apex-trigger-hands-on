trigger TaskcTrigger on Task__c (after update) {

    // 1️⃣ Collect Account Ids where Task status changed to Completed
    Set<Id> accIds = new Set<Id>();

    for (Task__c t : Trigger.new) {
        Task__c oldT = Trigger.oldMap.get(t.Id);

        if (t.Account__c != null 
            && t.Status__c != oldT.Status__c 
            && t.Status__c == 'Completed') {
            accIds.add(t.Account__c);
        }
    }

    if (accIds.isEmpty()) return;

    // 2️⃣ Aggregate query: count completed tasks per account
    Map<Id, Integer> taskMap = new Map<Id, Integer>();

    for (AggregateResult ar : [
        SELECT Account__c accId, COUNT(Id) taskCount
        FROM Task__c
        WHERE Account__c IN :accIds AND Status__c = 'Completed'
        GROUP BY Account__c
    ]) {
        taskMap.put((Id) ar.get('accId'), (Integer) ar.get('taskCount'));
    }

    // 3️⃣ Prepare Account records to update
    List<Account> accToUpdate = new List<Account>();

    for (Id acId : accIds) {
        accToUpdate.add(new Account(
            Id = acId,
            Completed_Tasks__c = taskMap.containsKey(acId) ? taskMap.get(acId) : 0
        ));
    }

    // 4️⃣ Update Accounts
    if (!accToUpdate.isEmpty()) {
        update accToUpdate;
    }
}
/*
How to automatically update an Account’s Completed_Tasks__c field whenever related Task__c records are updated to “Completed”, in a bulk-safe way?
*/
