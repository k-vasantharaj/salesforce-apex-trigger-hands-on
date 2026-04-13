//Question
Case – Status-Based Automation

Trigger on Case:

Before Insert → Set Origin = 'Phone' if not provided
After Insert → Create Task
After Update → If Status = ‘Escalated’, set Priority = ‘High’

//Trigger

trigger CaseTrigger on Case (before insert, after insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CaseTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
}

//Handler

public class CaseTriggerHandler {

    /**
     * Before Insert:
     * Set default Origin if not provided
     */
    public static void handleBeforeInsert(List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;

        for (Case c : newCases) {
            if (String.isBlank(c.Origin)) {
                c.Origin = 'Phone';
            }
        }
    }

    /**
     * After Insert:
     * Create follow-up Tasks
     */
    public static void handleAfterInsert(List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;

        List<Task> tasksToInsert = new List<Task>();

        for (Case c : newCases) {
            tasksToInsert.add(new Task(
                WhatId = c.Id,
                Subject = 'Case Created',
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    /**
     * Before Update:
     * Escalation handling
     */
    public static void handleBeforeUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        if (newCases == null || newCases.isEmpty()) return;

        for (Case c : newCases) {
            Case oldCase = oldMap.get(c.Id);

            if (oldCase == null) continue;

            if (c.Status != oldCase.Status && c.Status == 'Escalated') {
                c.Priority = 'High';
            }
        }
    }
}
