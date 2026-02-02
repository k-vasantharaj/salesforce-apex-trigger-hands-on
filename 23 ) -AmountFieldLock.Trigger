trigger opportunityTrigger on Opportunity (before update) {
    
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        
        // If Amount already has a value and user tries to change it, block the update
        if (oldOpp.Amount != null && opp.Amount != oldOpp.Amount) {
            opp.addError('You cannot modify Opportunity Amount once it has been set.');
        }
    }
}
/*
Question:

Once Amount is initially set on an Opportunity, it should not be changed again.
Write a before update trigger that prevents any modification to the Amount field by comparing old and new values.
*/

//Test class

@isTest
public class OpportunityTriggerTest {

    @isTest
    static void shouldPreventAmountDecrease() {

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 100000,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10)
        );
        insert testOpp;

        Boolean isExceptionThrown = false;

        try {
            testOpp.Amount = 1000; 
            update testOpp;
        } catch (DmlException ex) {
            isExceptionThrown = true;
        }

        System.assertEquals(
            true,
            isExceptionThrown,
            'Amount should not be allowed to decrease once set'
        );
    }


    @isTest
    static void shouldAllowStageProgressionWithoutAmountChange() {

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 100000,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10)
        );
        insert testOpp;

        Boolean isExceptionThrown = false;

        // Act
        try {
            testOpp.StageName = 'Qualification'; 
            update testOpp;
        } catch (DmlException ex) {
            isExceptionThrown = true;
        }

        // Assert
        System.assertEquals(
            false,
            isExceptionThrown,
            'Stage change should be allowed when amount is unchanged'
        );
    }
}
