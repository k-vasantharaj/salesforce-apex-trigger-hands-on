trigger AccountTrigger on Account (before delete) {

    DateTime currentTime = DateTime.now();
    DateTime last24Hours = currentTime.addHours(-24);

    for (Account acc : Trigger.old) {
        // Check if the record was modified within the last 24 hours
        if (acc.LastModifiedDate > last24Hours) {
            acc.addError('You cannot delete this Account because it was modified in the last 24 hours.');
        }
    }
}
/*
“How would you prevent deletion of an Account record if it was modified in the last 24 hours?”
*/
