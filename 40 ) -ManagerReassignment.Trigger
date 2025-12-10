trigger ManagerTrigger on Manager__c (before delete) {

    // Collect IDs of Managers being deleted
    Set<Id> managerIds = new Set<Id>();
    for (Manager__c m : Trigger.old) {
        if (m.Parent_Manager__c != null) { // only consider managers with a parent
            managerIds.add(m.Id);
        }
    }

    if (managerIds.isEmpty()) return;

    // Query employees whose managers are being deleted
    List<Employee__c> employeesToUpdate = new List<Employee__c>();
    Map<Id, Id> managerToParentMap = new Map<Id, Id>();

    // Build mapping of Manager -> Parent Manager
    for (Manager__c m : [SELECT Id, Parent_Manager__c FROM Manager__c WHERE Id IN :managerIds]) {
        managerToParentMap.put(m.Id, m.Parent_Manager__c);
    }

    // Query employees and reassign manager
    for (Employee__c e : [SELECT Id, Manager__c FROM Employee__c WHERE Manager__c IN :managerIds]) {
        e.Manager__c = managerToParentMap.get(e.Manager__c);
        employeesToUpdate.add(e);
    }

    // Update employees
    if (!employeesToUpdate.isEmpty()) {
        update employeesToUpdate;
    }
}
/*
“When a Manager__c record is deleted, how would you reassign all related Employee__c records to the Manager’s parent manager?”
*/
