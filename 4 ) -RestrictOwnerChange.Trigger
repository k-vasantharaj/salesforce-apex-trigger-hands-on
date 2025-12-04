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
