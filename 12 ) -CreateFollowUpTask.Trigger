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

//Test class

@IsTest
public class OpportunityTriggerSpec {

    @IsTest
    static void shouldCreateFollowUpTaskOnOpportunityInsert() {

        // Arrange
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );

        // Act
        insert opp;

        // Assert
        List<Task> createdTasks = [
            SELECT OwnerId, WhatId, Subject
            FROM Task
            WHERE WhatId = :opp.Id
        ];

        System.assertEquals(
            1,
            createdTasks.size(),
            'One follow-up task should be created'
        );

        System.assertEquals(
            opp.Id,
            createdTasks[0].WhatId,
            'Task should be related to the Opportunity'
        );

        System.assertEquals(
            opp.OwnerId,
            createdTasks[0].OwnerId,
            'Task should be assigned to Opportunity Owner'
        );

        System.assertEquals(
            'New task',
            createdTasks[0].Subject,
            'Task subject should match'
        );
    }
}

