trigger ContactPhoneDuplicateTrigger on Contact (before insert) {

    /*
     * When inserting Contacts,
     * if another Contact already exists with the same Phone number,
     * block the insert and show a validation error.
     */

    Set<String> phoneNumbers = new Set<String>();

    for (Contact con : Trigger.new) {
        if (con.Phone != null) {
            phoneNumbers.add(con.Phone);
        }
    }

    Map<String, Id> existingPhoneMap = new Map<String, Id>();

    for (Contact c : [
        SELECT Id, Phone
        FROM Contact
        WHERE Phone IN :phoneNumbers
    ]) {
        existingPhoneMap.put(c.Phone, c.Id);
    }

    for (Contact con : Trigger.new) {
        if (con.Phone != null && existingPhoneMap.containsKey(con.Phone)) {
            con.addError('A contact with this phone number already exists.');
        }
    }
}
