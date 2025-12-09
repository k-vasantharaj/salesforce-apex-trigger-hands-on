trigger studentTrigger on Student__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Student__c stu : Trigger.new) {

            if (stu.Date_of_birth__c != null) {

                // Calculate age in years using precise date difference
                Integer ageInYears = stu.Date_of_birth__c.daysBetween(Date.today()) / 365;

                stu.Age__c = ageInYears;
            }
        }
    }
}
/*
 Whenever a new Student record is created,
automatically calculate the student’s age based on the Date_of_birth__c field and populate it into the Age__c field before insert.
*/
