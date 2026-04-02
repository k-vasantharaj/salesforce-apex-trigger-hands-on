/*Question
Case Auto Assignment Logic

When a Case is created:

If Priority = High → assign to "High Priority Queue"
If Origin = Email → set Status = New
If Subject contains "Refund" → mark Type = Escalation
Ensure logic supports bulk inserts
*/

//Trigger
trigger CaseTrigger on Case (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        TriggerHandler.caseAutoAssign(Trigger.new);
    }
}

//Handler

public class TriggerHandler {

    public static void caseAutoAssign(List<Case> caseList) {

        if (caseList == null || caseList.isEmpty()) {
            return;
        }

        // Fetch High Priority Queue Id
        Id highPriorityQueueId;
        List<Group> queueList = [
            SELECT Id
            FROM Group
            WHERE Name = 'High Priority Queue'
            AND Type = 'Queue'
            LIMIT 1
        ];

        if (!queueList.isEmpty()) {
            highPriorityQueueId = queueList[0].Id;
        }

        for (Case c : caseList) {

            // 1. Priority = High → assign to Queue
            if (c.Priority == 'High' && highPriorityQueueId != null) {
                c.OwnerId = highPriorityQueueId;
            }

            // 2. Origin = Email → Status = New
            if (c.Origin == 'Email') {
                c.Status = 'New';
            }

            // 3. Subject contains 'Refund' → Type = Escalation
            if (c.Subject != null && 
                c.Subject.toLowerCase().contains('refund')) {
                c.Type = 'Escalation';
            }
        }
    }
}
