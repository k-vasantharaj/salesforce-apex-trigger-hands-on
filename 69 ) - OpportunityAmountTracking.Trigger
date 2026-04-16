//Question
Opportunity – Amount Change Tracking

Trigger on Opportunity:

Before Update → If Amount changes, update Description with old and new values
After Update → If Amount decreases, create a Task

//Trigger

trigger OpportunityTrigger on Opportunity (before update, after update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityAmountHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityAmountHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}

//Handler

public class OpportunityAmountHandler {

    /*
     * Purpose:
     * Tracks Opportunity Amount changes
     * - Before Update: Update Description with old and new Amount
     * - After Update: Create Task if Amount decreases
     */

    public static void handleBeforeUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        if (newOppList == null || newOppList.isEmpty()) return;

        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);

            if (newOpp.Amount != oldOpp.Amount && newOpp.Amount != null) {
                newOpp.Description = 'Old Value: ' + oldOpp.Amount + ' | New Value: ' + newOpp.Amount;
            }
        }
    }

    public static void handleAfterUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        if (newOppList == null || newOppList.isEmpty()) return;

        List<Task> tasksToInsert = new List<Task>();

        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);

            tasksToInsert.add(new Task(
             WhatId = newOpp.Id,
             Subject = 'Opportunity Amount Decreased',
             Description = 'Amount reduced from ' + oldOpp.Amount + ' to ' + newOpp.Amount,
             OwnerId = newOpp.OwnerId,
             Priority = 'High',
             Status = 'Not Started',
             ActivityDate = Date.today().addDays(1)
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
