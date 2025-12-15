trigger AccountTrigger on Account (
    before insert, after insert,
    before update, after update,
    before delete, after delete,
    after undelete
) {
    AccountTriggerHandler.run();
}


public class AccountTriggerHandler {

    private static Boolean isExecuting = false;

    public static void run() {
        if (isExecuting) return;
        isExecuting = true;

        if (Trigger.isBefore && Trigger.isInsert) {
            beforeInsert();
        }
    }

    private static void beforeInsert() {
        for (Account acc : Trigger.new) {

            // Business Rule:
            // If Rating is 'Hot' and AnnualRevenue is blank,
            // automatically set AnnualRevenue to 20000
            if (acc.Rating == 'Hot' && acc.AnnualRevenue == null) {
                acc.AnnualRevenue = 20000;
            }
        }
    }
}
/*
When creating an Account, if the Rating is set to Hot and AnnualRevenue is left blank, 
the system should automatically populate AnnualRevenue = 20000 before the record is inserted.
Implement this using a Trigger with a Handler pattern.
*/
