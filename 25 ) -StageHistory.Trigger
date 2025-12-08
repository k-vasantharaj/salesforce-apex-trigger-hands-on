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
