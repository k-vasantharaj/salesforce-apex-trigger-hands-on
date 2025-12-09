trigger caseTrigger on Case (before update) {


    for (Case c : Trigger.New) {
        Case oldC = Trigger.oldMap.get(c.Id);

        // Check if Description changed
        if (oldC.Description != c.Description) {

            // If status is already closed OR becoming closed
            if (c.Status == 'Closed') {
                c.Description.addError('Description cannot be modified when Status is Closed.');
            }
        }
    }
}
/*
When a Case status becomes Closed or is already Closed, users must not be allowed to change the Description field.
*/
