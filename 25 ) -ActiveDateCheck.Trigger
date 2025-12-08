trigger SubscriptionTrigger on Subscription__c (before update) {

    for (Subscription__c sub : Trigger.new) {
        Subscription__c oldSub = Trigger.oldMap.get(sub.Id);

        Boolean statusChangedToActive = 
            oldSub.Status__c != 'Active' && sub.Status__c == 'Active';

        Boolean endDateChanged = 
            oldSub.End_Date__c != sub.End_Date__c;

        // Validation when subscription is Active & End Date is not future
        if (sub.Status__c == 'Active' &&
            (statusChangedToActive || endDateChanged) &&
            (sub.End_Date__c == null || sub.End_Date__c <= Date.today())) {
            
            sub.addError('Active subscriptions must have an End Date set to a future date.');
        }
    }
}

    /*
       How do you restrict an Active Subscription from having an End Date that is today or in the past?

     */
