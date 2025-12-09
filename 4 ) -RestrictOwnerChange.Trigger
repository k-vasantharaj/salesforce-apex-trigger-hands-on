trigger caseOwnerRestriction on Case (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {

        for (Case newCase : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(newCase.Id);

            // Restrict Owner change
            if (newCase.OwnerId != oldCase.OwnerId) {
                newCase.addError('You are not allowed to change the Case Owner.');
            }
        }
    }
}
/*
 Your organization has a rule that once a Case is created, the Case Owner must remain unchanged. 
Users should not be allowed to modify the owner after the record is inserted in the system.

*/
