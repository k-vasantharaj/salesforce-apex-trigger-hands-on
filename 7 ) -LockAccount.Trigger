trigger contactTrigger on Contact (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {

        for (Contact con : Trigger.new) {
            Contact oldContact = Trigger.oldMap.get(con.Id);

            // Prevent modifying Account once set
            if (con.AccountId != oldContact.AccountId) {
                con.addError('Once Contact.AccountId is set, it cannot be changed.');
            }
        }
    }
}
