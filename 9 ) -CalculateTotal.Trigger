trigger invoiceTrigger on Invoice__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Invoice__c inv : Trigger.New) {

            Decimal quantity = inv.Quantity__c != null ? inv.Quantity__c : 0;
            Decimal unitPrice = inv.Unit_Price__c != null ? inv.Unit_Price__c : 0;

            inv.Total_Amount__c = quantity * unitPrice;
        }
    }
}
/*
When a new Invoice record is created, 
automatically calculate Total_Amount__c as Quantity × Unit Price before inserting the record.
*/
