trigger caseTrigger on Case (before update) {

    // Allowed status flow only: New → In Progress → Resolved → Closed

    for (Case c : Trigger.New) {
        Case oldCase = Trigger.oldMap.get(c.Id);

        if (oldCase.Status != c.Status) {

            if(oldCase.Status == 'In Progress' && c.Status == 'New') {
                c.Status.addError('Cannot change from In Progress to New.');
            }
            else if(oldCase.Status == 'Resolved' && 
                   (c.Status == 'New' || c.Status == 'In Progress')) {
                c.Status.addError('Cannot move backward from Resolved.');
            }
            else if(oldCase.Status == 'Closed' && 
                   (c.Status == 'New' || c.Status == 'In Progress' || c.Status == 'Resolved')) {
                c.Status.addError('Cannot move backward from Closed.');
            }
        }
    }
}

/*
 Question:
 Prevent users from changing the Case Status backwards.
 Allowed flow:
 New → In Progress → Resolved → Closed
 Block any backward movement and display an error message.
*/
