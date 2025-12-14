trigger OrderLineTrigger on Order_Line__c (before update) {

    /*
     * Object: Order_Line__c
     * Fields: Quantity__c, Discount__c
     *
     * Rules:
     * Qty < 10  → 0%
     * 10–49     → 5%
     * 50+       → 10%
     */

    for (Order_Line__c ol : Trigger.new) {

        Order_Line__c oldOl = Trigger.oldMap.get(ol.Id);

        // Recalculate only when Quantity changes
        if (ol.Quantity__c != oldOl.Quantity__c && ol.Quantity__c != null) {

            Decimal qt = ol.Quantity__c;

            ol.Discount__c =
                qt < 10 ? 0 :
                qt < 50 ? 5 : 10;
        }
    }
}
/*
When the Quantity__c field on Order_Line__c is updated,
automatically recalculate Discount__c using the rules: Quantity < 10 → 0%, 10–49 → 5%, 50+ → 10%. 
The solution must be bulk-safe and update the discount only when the quantity changes.
*/
