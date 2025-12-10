trigger ParentTrigger on Parent__c (after delete) {

    /*
     * Requirement:
     * - When Parent__c is deleted, Child__c (Master-Detail) auto deletes.
     * - Insert a ParentDeletionLog__c record with Parent Name + Parent Id.
     * - Must be bulk-safe and clean.
     */

    List<ParentDeletionLog__c> logList = new List<ParentDeletionLog__c>();

    for (Parent__c p : Trigger.old) {
        logList.add(new ParentDeletionLog__c(
            Name = p.Name,
            ParentId__c = p.Id
        ));
    }

    if (!logList.isEmpty()) {
        insert logList;
    }
}

/*
When a Parent__c record is deleted, all its related Child__c records (Master-Detail) are automatically deleted by Salesforce.
But the business wants to log the Parent Name and Parent Id into a custom ParentDeletionLog__c object.
Write an after delete trigger that inserts a log record for every deleted parent.
*/
