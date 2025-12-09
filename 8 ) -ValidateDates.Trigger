trigger subscriptionTrigger on Subscription__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Subscription__c sub : Trigger.new) {

            // Validate Start and End Dates
            if (sub.Start_Date__c != null && sub.End_Date__c != null && sub.Start_Date__c > sub.End_Date__c) {
                sub.addError('Start Date cannot be after End Date.');
            }
        }
    }
}
/*
When a Subscription record is created, ensure the Start Date is not greater than the End Date, 
and show an error if the dates are invalid.
*/
