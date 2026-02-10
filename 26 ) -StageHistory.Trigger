trigger OpportunityTrigger on Opportunity (before update) {   

    for (Opportunity opp : Trigger.new) {

        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        // If StageName is modified, store previous stage
        if (oldOpp.StageName != null &&
            opp.StageName != oldOpp.StageName) {
            
            opp.Previous_Stage__c = oldOpp.StageName;
        }
    }

}

 /*
 How do you track the previous stage of an Opportunity when StageName changes?
     */

//Testclass

@isTest
public class OpportunityTriggerTest {

    @isTest
    static void testPreviousStageIsCaptured() {

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        opp.StageName = 'Qualification';

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity updatedOpp = [
            SELECT Previous_Stage__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(
            'Prospecting',
            updatedOpp.Previous_Stage__c,
            'Previous stage should be stored correctly.'
        );
    }
}
