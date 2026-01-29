trigger LeadTrigger on Lead (after insert) {

    List<Task> taskList = new List<Task>();

    for (Lead ld : Trigger.new) {
        if (ld.Status == 'Open - Not Contacted') {
            taskList.add(new Task(
                OwnerId = ld.OwnerId,
                WhoId = ld.Id,
                Subject = 'Follow-Up with Lead',
                Priority = 'Normal',
                Status = 'Not Started'
            ));
        }
    }

    if (!taskList.isEmpty()) {
        insert taskList;
    }
}
/*
On Lead creation, if Status = "Open - Not Contacted", automatically create a Task assigned to the Lead Owner. Write the trigger using best practices.

*/

//Test class

@isTest
public class asyncDemo {

    // ✅ Task should be created
    @isTest
    static void opportunity_taskCreated() {

        Lead l = new Lead();
        l.Salutation = 'Mr';
        l.LastName = 'l1_' + System.currentTimeMillis();
        l.Company = 'tcs';
        l.Status = 'Open - Not Contacted';

        Test.startTest();
        insert l;
        Test.stopTest();

        List<Task> taskList = [
            SELECT WhoId, Subject
            FROM Task
            WHERE WhoId = :l.Id
        ];

        System.assertEquals(1, taskList.size(), 'Task must be created');
        System.assertEquals('New Lead created', taskList[0].Subject);
    }

    // ❌ Task should NOT be created
    @isTest
    static void opportunity_taskNotCreated() {

        Lead l = new Lead();
        l.Salutation = 'Mr';
        l.LastName = 'l2_' + System.currentTimeMillis();
        l.Company = 'tcs';
        l.Status = 'Working - Contacted';

        Test.startTest();
        insert l;
        Test.stopTest();

        List<Task> taskList = [
            SELECT Id
            FROM Task
            WHERE WhoId = :l.Id
        ];

        System.assertEquals(0, taskList.size(), 'Task must not be created');
    }
}
