//ProjectTrigger

trigger ProjectTrigger on Project__c (after delete) {

    TriggerHandler.deleteProjectPermission(Trigger.old);
}

/*
When a Project__c record is deleted, all related ProjectPermission__c records must also be deleted.
However, any permission record where Is_Global__c = true should NOT be deleted. 
Write an after delete trigger on Project__c that deletes only the non-global ProjectPermission__c records.
*/

//TriggerHandler

public class TriggerHandler {

    public static void deleteProjectPermission(List<Project__c> oldProjects){

        Set<Id> projectIds = new Set<Id>();

        for(Project__c p : oldProjects){
            projectIds.add(p.Id);
        }

        if(projectIds.isEmpty()){
            return;
        }

        List<ProjectPermission__c> ppList = [
            SELECT Id
            FROM ProjectPermission__c
            WHERE Is_Global__c = false
            AND Project__c IN :projectIds
        ];

        if(!ppList.isEmpty()){
            delete ppList;
        }
    }
}
