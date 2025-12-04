trigger leadTrigger on Lead (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Lead l : Trigger.new) {

            if (l.Status == null) {
                l.Status = 'New';
            }
            if (l.Rating == null) {
                l.Rating = 'Warm';
            }
        }
    }
}
