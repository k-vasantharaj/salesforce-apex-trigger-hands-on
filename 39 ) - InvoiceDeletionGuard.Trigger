trigger InvoiceTrigger on Invoice__c (before delete) {

    // Collect Invoice IDs being deleted
    Set<Id> invoiceIds = new Set<Id>();
    for (Invoice__c inv : Trigger.old) {
        invoiceIds.add(inv.Id);
    }

    if (invoiceIds.isEmpty()) return;

    // Query related pending payments
    Set<Id> invoicesWithPendingPayments = new Set<Id>();
    for (Payment__c pay : [
        SELECT Id, Invoice__c 
        FROM Payment__c
        WHERE Invoice__c IN :invoiceIds
          AND Status__c = 'Pending'
    ]) {
        invoicesWithPendingPayments.add(pay.Invoice__c);
    }

    // Block deletion for invoices with pending payments
    for (Invoice__c inv : Trigger.old) {
        if (invoicesWithPendingPayments.contains(inv.Id)) {
            inv.addError('You cannot delete this Invoice because it has pending payments.');
        }
    }
}
/*
“How do you prevent an Invoice__c from being deleted when it has related Payment__c records in ‘Pending’ status?”
*/
