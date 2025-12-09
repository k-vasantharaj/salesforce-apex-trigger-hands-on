trigger CaseDefaultPriority on Case (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Case cs : Trigger.new) {

            // If Priority is not provided, set default value
            if (cs.Priority == null) {
                cs.Priority = 'Medium';
            }
        }
    }
}
/*
 When a new Case is created, and if Priority is left blank, auto-set Priority = 'Medium'.
*/
