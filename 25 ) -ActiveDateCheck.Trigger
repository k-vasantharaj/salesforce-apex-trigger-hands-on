trigger SubscriptionTrigger on Subscription__c (before insert, before update) {

    for (Subscription__c sub : Trigger.New) {

        if (sub.Status__c == 'Active' &&
            sub.End_Date__c != null &&
            sub.End_Date__c <= Date.today()) {

            sub.addError('End Date must be a future date for Active subscriptions.');
        }
    }
}


    /*
       How do you restrict an Active Subscription from having an End Date that is today or in the past?

     */
