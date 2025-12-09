trigger AutoProbationEnd on Employee__c (before insert) {

    // Loop through all new Employee records
    for (Employee__c emp : Trigger.new) {

        // Only set Probation_End__c if Joining_Date__c is populated
        if (emp.Joining_Date__c != null) {
            emp.Probation_End__c = emp.Joining_Date__c.addDays(90);
        }
    }
}
/*
On inserting a new Employee__c record, automatically set Probation_End__c to be 90 days after Joining_Date__c.
*/
