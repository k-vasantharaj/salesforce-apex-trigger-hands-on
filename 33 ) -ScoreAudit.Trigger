trigger LeadTrigger on Lead (after update) {

    List<Lead_Audit__c> auditRecords = new List<Lead_Audit__c>();

    for (Lead newL : Trigger.new) {
        Lead oldL = Trigger.oldMap.get(newL.Id);

        // Check if Score field changed
        if (newL.Score__c != oldL.Score__c) {

            auditRecords.add(new Lead_Audit__c(
                OldValue__c = oldL.Score__c,
                NewValue__c = newL.Score__c,
                LeadId__c = newL.Id,
                UserId__c = UserInfo.getUserId()
            ));
        }
    }

    if (!auditRecords.isEmpty()) {
        insert auditRecords;
    }
}

/*
“When Lead.Score__c changes, create a Lead_Audit__c record logging the old value, new value, Lead Id, and User Id.”
*/
