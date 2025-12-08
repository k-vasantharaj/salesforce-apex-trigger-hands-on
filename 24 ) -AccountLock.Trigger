trigger ContactTrigger on Contact (before update) {

    /*
     * QUESTION (Command-Line Style):
     * Q: How will you restrict updating AccountId for Contacts 
     *    once it is already associated with an Account?
     * A: By using a before update trigger and validating changes 
     *    using Trigger.oldMap. (Implementation below)
     */

    for (Contact con : Trigger.new) {
        Contact oldCon = Trigger.oldMap.get(con.Id);

        // Restrict changing AccountId once set
        if (oldCon.AccountId != null && con.AccountId != oldCon.AccountId) {
            con.addError('You cannot change the Account once it is set.');
        }
    }

}
/*
How can you prevent users from modifying AccountId on an existing Contact record?
*/
