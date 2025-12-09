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
/*
To maintain standardized Lead creation process, 
the system must ensure default values are assigned when certain fields are not provided. 
When a new Lead record is inserted, if the Status field is not filled by the user, 
the system should automatically set it to "New". Similarly, if the Rating field is left blank, it should default to "Warm".
*/
