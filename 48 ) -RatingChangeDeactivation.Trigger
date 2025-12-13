trigger AccountTrigger on Account (before update) {

    for (Account acc : Trigger.new) {

        Account oldAcc = Trigger.oldMap.get(acc.Id);

        if (
            oldAcc.Rating != null &&
            oldAcc.Rating == 'Hot' &&
            acc.Rating == 'Cold' &&
            acc.AnnualRevenue == null
        ) {
            acc.Active__c = 'No';
        }
    }
}
/*
When an Account record is updated, if the Rating changes from Hot to Cold and AnnualRevenue is blank, the Active__c field must be automatically set to 'No'.
*/
