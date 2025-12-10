trigger CustomerTrigger on Customer__c (before delete) {

    // List to hold records for soft delete update
    List<Customer__c> softDeleteList = new List<Customer__c>();

    // Loop through all records being deleted
    for (Customer__c cust : Trigger.old) {

        // Stop the hard delete
        cust.addError('Soft delete: record will not be hard deleted.');

        // Prepare record to set Is_Deleted__c = true
        softDeleteList.add(new Customer__c(
            Id = cust.Id,
            Is_Deleted__c = true
        ));
    }

    // Perform the soft delete update
    if (!softDeleteList.isEmpty()) {
        update softDeleteList;
    }
}
/*
Write a Salesforce before delete trigger on Customer__c that prevents hard deletion and instead sets a custom field Is_Deleted__c = true. 
Ensure the trigger works in bulk and shows an error message to the user indicating a soft delete has occurred.
*/
