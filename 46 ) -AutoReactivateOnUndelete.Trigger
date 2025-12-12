trigger ContactTrigger on Contact (before delete, after undelete) {

    /*
     * Requirement:
     * Contact__c has a Boolean field Was_Active_Before_Deletion__c.
     * If the contact was active before deletion, store that value.
     * When the contact is undeleted, automatically activate it again.
     */

    // PART 1 — Store active state BEFORE DELETE
    if (Trigger.isBefore && Trigger.isDelete) {
        for (Contact con : Trigger.old) {
            // If the contact is currently active, save that info
            if (con.Active__c == true) {
                con.Was_Active_Before_Deletion__c = true;
            } else {
                con.Was_Active_Before_Deletion__c = false;
            }
        }
    }

    // PART 2 — Restore active state AFTER UNDELETE
    if (Trigger.isAfter && Trigger.isUndelete) {

        List<Contact> toUpdate = new List<Contact>();

        for (Contact con : Trigger.new) {

            // If it was active before deletion → reactivate it
            if (con.Was_Active_Before_Deletion__c == true) {
                Contact c = new Contact();
                c.Id = con.Id;
                c.Active__c = true;
                toUpdate.add(c);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}
/*
When a Contact record is deleted, the system must remember whether it was active at the time of deletion (using the field Was_Active_Before_Deletion__c). 
Later, if the user undeletes the Contact, and it was previously active,
the Contact should automatically become active again. Implement this behavior using a trigger on Contact.
*/
