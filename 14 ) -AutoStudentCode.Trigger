trigger studentTrigger on Student__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        Integer maxSeq = 0;

        // Fetch the latest existing record to continue the sequence
        Student__c lastRec = [
            SELECT Code__c
            FROM Student__c
            WHERE Code__c != NULL
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (lastRec.Code__c != null) {
            String numPart = lastRec.Code__c.replace('Emp-', '');
            maxSeq = Integer.valueOf(numPart);
        }

        for (Student__c stu : Trigger.new) {
            maxSeq++;
            stu.Code__c = 'Emp-' + maxSeq;
        }
    }
}
/*
 Whenever a new Student__c record is created, the system must automatically generate a unique Code__c in the format Emp-<RunningNumber>,
where the running number should continue from the last existing record in Salesforce.
*/
