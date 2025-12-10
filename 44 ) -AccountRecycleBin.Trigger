trigger AccountTrigger on Account (after delete) {

    /*
     * Requirement:
     * When an Account is deleted, insert a new Recycle_Bin__c record 
     * containing Account fields:
     * Name, Industry, Rating, OwnerId, CreatedDate
     */

    List<Recycle_Bin__c> recordsToInsert = new List<Recycle_Bin__c>();

    for (Account acc : Trigger.old) {
        Recycle_Bin__c binRecord = new Recycle_Bin__c();
        binRecord.Name = acc.Name;
        binRecord.Industry__c = acc.Industry;
        binRecord.Rating__c = acc.Rating;
        binRecord.OwnerId__c = acc.OwnerId;
        binRecord.Original_Created_Date__c = acc.CreatedDate; // assuming field exists
        recordsToInsert.add(binRecord);
    }

    if (!recordsToInsert.isEmpty()) {
        insert recordsToInsert;
    }
}
/*
Whenever an Account record is deleted, the company wants to store its key fields (Name, Industry, Rating, OwnerId, CreatedDate) in a custom object called Recycle_Bin__c. Write an after delete trigger that inserts these field values into Recycle_Bin__c.
*/
