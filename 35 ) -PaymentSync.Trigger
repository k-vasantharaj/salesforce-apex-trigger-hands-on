trigger InvoiceTrigger on Invoice__c (after update) {

    List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();

    for (Invoice__c newInv : Trigger.new) {
        Invoice__c oldInv = Trigger.oldMap.get(newInv.Id);

        // Update only when Status becomes "Paid"
        if (newInv.Status__c != oldInv.Status__c &&
            newInv.Status__c == 'Paid') {

            invoicesToUpdate.add(new Invoice__c(
                Id = newInv.Id,
                Payment_Date__c = System.today()
            ));
        }
    }

    if (!invoicesToUpdate.isEmpty()) {
        update invoicesToUpdate;
    }
}
/*
“When Invoice__c.Status__c changes to ‘Paid’, automatically set Payment_Date__c to today’s date using an after-update trigger.”
*/
