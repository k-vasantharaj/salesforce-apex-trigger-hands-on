trigger CaseTrigger on Case (before update) {

    for (Case newCase : Trigger.new) {

        Case oldCase = Trigger.oldMap.get(newCase.Id);

        // Prevent Description change if Case is already closed
        // or being changed to Closed
        if ((oldCase.Status == 'Closed' || newCase.Status == 'Closed') &&
            oldCase.Description != newCase.Description) {

            newCase.Description.addError(
                'Description cannot be changed once the Case is closed.'
            );
        }
    }
}

/*
When a Case status becomes Closed or is already Closed, users must not be allowed to change the Description field.
*/

//Test class


trigger CaseTrigger on Case (before update) {

    for (Case newCase : Trigger.new) {

        Case oldCase = Trigger.oldMap.get(newCase.Id);

        // Prevent Description change if Case is already closed
        // or being changed to Closed
        if ((oldCase.Status == 'Closed' || newCase.Status == 'Closed') &&
            oldCase.Description != newCase.Description) {

            newCase.Description.addError(
                'Description cannot be changed once the Case is closed.'
            );
        }
    }
}
