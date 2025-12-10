trigger AccountTrigger on Account (before delete) {

    Id currentUserId = UserInfo.getUserId();

    for (Account acc : Trigger.old) {
        // If the logged-in user owns the record, block deletion
        if (acc.OwnerId == currentUserId) {
            acc.addError('You cannot delete your own Account record.');
        }
    }
}
/*
“How would you prevent a user from deleting their own Account record in Salesforce using a trigger?”
*/
