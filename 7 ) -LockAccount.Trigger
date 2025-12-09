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
/*
- Your company has a data integrity rule that once a Contact record is linked to an Account, 
this relationship must remain unchanged. 
Users should be allowed to set the AccountId for a Contact only when the record is being created.
However, after the Contact has been inserted, the Account assignment should be locked.
*/
