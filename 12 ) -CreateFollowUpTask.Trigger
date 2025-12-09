trigger opportunityTrigger on Opportunity (after insert) {

    List<Task> tasksToInsert = new List<Task>();

    for (Opportunity opp : Trigger.New) {
        if (opp.OwnerId != null) {
            tasksToInsert.add(new Task(
                Subject = 'Follow up on new Opportunity: ' + opp.Name,
                WhatId = opp.Id,
                OwnerId = opp.OwnerId,
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }
    }

    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }
}
/*
When a new Opportunity is created, automatically create a follow-up Task assigned to the Opportunity Owner.
*/
