trigger DuplicateCasePrevention on Case (before insert) {

    // Collect valid ContactIds from incoming records
    Set<Id> contactIds = new Set<Id>();
    for (Case c : Trigger.new) {
        if (c.ContactId != null && c.Subject != null) {
            contactIds.add(c.ContactId);
        }
    }

    if (contactIds.isEmpty()) return;

    // Create a Set to store existing duplicate combinations
    Set<String> existingKeys = new Set<String>();

    // ONE SOQL: fetch existing duplicate candidate cases
    for (Case existing : [
        SELECT Subject, ContactId
        FROM Case
        WHERE ContactId IN :contactIds
        AND Subject != null
        AND CreatedDate >= :DateTime.now().addDays(-30)
    ]) {
        existingKeys.add(existing.Subject.toLowerCase() + ':' + existing.ContactId);
    }

    // Validate new records before insert
    for (Case c : Trigger.new) {
        if (c.ContactId != null && c.Subject != null) {
            String key = c.Subject.toLowerCase() + ':' + c.ContactId;
            if (existingKeys.contains(key)) {
                c.addError('Duplicate case detected: Same Contact & Subject exists within last 30 days.');
            }
        }
    }
}
/*
On inserting a new Employee__c record, automatically set Probation_End__c to be 90 days after Joining_Date__c.
*/
