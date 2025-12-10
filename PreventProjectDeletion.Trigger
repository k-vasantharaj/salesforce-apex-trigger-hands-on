trigger ProjectTrigger on Project__c (before delete) {

    // Collect IDs of Projects being deleted
    Set<Id> projectIds = new Set<Id>();
    for (Project__c proj : Trigger.old) {
        projectIds.add(proj.Id);
    }

    // Query all open Tasks__c related to these Projects
    Map<Id, List<Task__c>> taskMap = new Map<Id, List<Task__c>>();
    for (Task__c t : [
        SELECT Name, Project__c
        FROM Task__c
        WHERE Project__c IN :projectIds
        AND Status__c = 'Open'
    ]) {
        taskMap.computeIfAbsent(t.Project__c, (k) -> new List<Task__c>());
        taskMap.get(t.Project__c).add(t);
    }

    // Block deletion and show the list of Task names
    for (Project__c proj : Trigger.old) {
        if (taskMap.containsKey(proj.Id)) {

            List<String> names = new List<String>();
            for (Task__c t : taskMap.get(proj.Id)) {
                names.add(t.Name);
            }

            proj.addError(
                'Cannot delete this Project. Open Tasks found: ' +
                String.join(names, ', ')
            );
        }
    }
}
/*
Write a Salesforce before delete trigger on Project__c that prevents deletion when the Project has any open related Task__c records, 
and display an error listing the names of those open Tasks.
*/
