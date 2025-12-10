trigger ProjectTrigger on Project__c (after delete) {

    /*
     * Requirement:
     * When a Project__c is deleted, delete all related ProjectPermission__c records
     * except those where Is_Global__c = true.
     */

    // Collect IDs of deleted Projects
    Set<Id> projectIds = new Set<Id>();
    for (Project__c proj : Trigger.old) {
        projectIds.add(proj.Id);
    }

    // Query all related permissions except global ones
    List<ProjectPermission__c> permissionsToDelete = [
        SELECT Id
        FROM ProjectPermission__c
        WHERE Project__c IN :projectIds
        AND Is_Global__c = FALSE
    ];

    // Delete only non-global records
    if (!permissionsToDelete.isEmpty()) {
        delete permissionsToDelete;
    }
}
/*
When a Project__c record is deleted, all related ProjectPermission__c records must also be deleted.
However, any permission record where Is_Global__c = true should NOT be deleted. 
Write an after delete trigger on Project__c that deletes only the non-global ProjectPermission__c records.
*/
