//Question
 Opportunity – Close Date Enforcement

Trigger on Opportunity:

Before Insert → If Stage = ‘Closed Won’, CloseDate must be today or earlier
Before Update → Prevent changing CloseDate after Closed Won
After Update → If Closed Won, create Task



//Trigger
trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}

//Handler

public class OpportunityTriggerHandler {

    /**
     * BEFORE INSERT
     * Ensures CloseDate is not in the future when Stage = Closed Won
     */
    public static void handleBeforeInsert(List<Opportunity> newOpportunities) {

        if (newOpportunities == null || newOpportunities.isEmpty()) return;

        Date today = Date.today();

        for (Opportunity opp : newOpportunities) {
            if (opp.StageName == 'Closed Won' && opp.CloseDate > today) {
                opp.addError('Close Date must be today or earlier for Closed Won opportunities.');
            }
        }
    }

    /**
     * BEFORE UPDATE
     * Prevents modification of CloseDate after Opportunity is Closed Won
     */
    public static void handleBeforeUpdate(List<Opportunity> newOpportunities,
                                          Map<Id, Opportunity> oldOpportunityMap) {

        if (newOpportunities == null || newOpportunities.isEmpty()) return;

        for (Opportunity opp : newOpportunities) {

            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);

            if (oldOpp.StageName == 'Closed Won' &&
                opp.CloseDate != oldOpp.CloseDate) {

                opp.addError('Close Date cannot be modified after the Opportunity is Closed Won.');
            }
        }
    }

    /**
     * AFTER UPDATE
     * Creates a follow-up Task when Opportunity is marked as Closed Won
     */
    public static void handleAfterUpdate(List<Opportunity> newOpportunities,
                                         Map<Id, Opportunity> oldOpportunityMap) {

        if (newOpportunities == null || newOpportunities.isEmpty()) return;

        List<Task> tasksToInsert = new List<Task>();

        for (Opportunity opp : newOpportunities) {

            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);

            if (opp.StageName != oldOpp.StageName &&
                opp.StageName == 'Closed Won') {

                Task followUpTask = new Task();
                followUpTask.OwnerId = opp.OwnerId;
                followUpTask.Subject = 'Follow up on Closed Won Opportunity';
                followUpTask.WhatId = opp.Id;
                followUpTask.Status = 'Not Started';
                followUpTask.Priority = 'Normal';

                tasksToInsert.add(followUpTask);
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
