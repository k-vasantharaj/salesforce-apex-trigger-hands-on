trigger ProjectTrigger on Project__c (after update) {

    List<Project__c> projectsToUpdate = new List<Project__c>();

    for (Project__c newP : Trigger.new) {
        Project__c oldP = Trigger.oldMap.get(newP.Id);

        // Check if important fields changed
        if (newP.Status__c != oldP.Status__c ||
            newP.Budget__c != oldP.Budget__c) {

            projectsToUpdate.add(
                new Project__c(
                    Id = newP.Id,
                    Last_Updated_By__c = UserInfo.getUserId()
                )
            );
        }
    }

    if (!projectsToUpdate.isEmpty()) {
        update projectsToUpdate;
    }
}
/*
“Update Last_Updated_By__c only when specific fields in Project__c are modified.”
*/
