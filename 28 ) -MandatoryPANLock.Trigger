trigger studentTrigger on Student__c (before update) {

    Set<Id> changedIds = new Set<Id>();

    // Identify records where PAN number got changed
    for (Student__c stu : Trigger.new) {
        Student__c oldStu = Trigger.oldMap.get(stu.Id);

        if (stu.PAN_Number__c != oldStu.PAN_Number__c) {
            changedIds.add(stu.Id);
        }
    }

    // Query existing PAN numbers for changed records (only where PAN was already set)
    Map<Id, String> existingPANMap = new Map<Id, String>();

    for (Student__c stu : [
        SELECT Id, PAN_Number__c
        FROM Student__c
        WHERE Id IN :changedIds
        AND PAN_Number__c != null
    ]) {
        existingPANMap.put(stu.Id, stu.PAN_Number__c);
    }

    // Prevent clearing the PAN number
    for (Student__c stu : Trigger.new) {
        if (stu.PAN_Number__c == null && existingPANMap.containsKey(stu.Id)) {
            stu.addError('PAN Number cannot be cleared once entered.');
        }
    }
}
/*

 Prevent clearing the PAN_Number__c field after it has been filled once.
If a value already exists, user should not be able to update it to null.
*/
