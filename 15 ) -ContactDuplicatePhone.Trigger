trigger ContactDuplicatePhone on Contact (before insert) {

    // Collect phone numbers from incoming records
    Set<String> phoneSet = new Set<String>();
    for (Contact con : Trigger.new) {
        if (con.Phone != null) {
            phoneSet.add(con.Phone);
        }
    }

    if (!phoneSet.isEmpty()) {

        // Query existing contacts with same phone
        Map<String, Id> existingPhones = new Map<String, Id>();

        for (Contact con : [
            SELECT Id, Phone
            FROM Contact
            WHERE Phone IN :phoneSet
        ]) {
            existingPhones.put(con.Phone, con.Id);
        }

        // Compare and add errors
        for (Contact con : Trigger.new) {
            if (con.Phone != null && existingPhones.containsKey(con.Phone)) {
                con.addError('A contact with this phone number already exists.');
            }
        }
    }
}
/*
 When inserting Contacts, if another Contact already exists with the same Phone number, block the insert and show a validation error.
*/
