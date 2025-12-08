// Topic: AmountFieldLock
// Question: Prevent users from modifying the Opportunity Amount field after it is first set.

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
