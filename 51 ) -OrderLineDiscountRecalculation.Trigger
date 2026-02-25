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

//Test class

@isTest
public class TestDemo {

    @isTest
    static void testDiscountRecalculationOnQuantityUpdate() {

        List<Order_Line__c> lines = new List<Order_Line__c>{
            new Order_Line__c(Name='OL1', Quantity__c=5),
            new Order_Line__c(Name='OL2', Quantity__c=5),
            new Order_Line__c(Name='OL3', Quantity__c=5)
        };

        insert lines;

        Test.startTest();

        lines[0].Quantity__c = 8;
        lines[1].Quantity__c = 40;
        lines[2].Quantity__c = 70;

        update lines;

        Test.stopTest();

        Map<Id, Order_Line__c> updatedMap = new Map<Id, Order_Line__c>(
            [SELECT Discount__c FROM Order_Line__c WHERE Id IN :lines]
        );

        System.assertEquals(0, updatedMap.get(lines[0].Id).Discount__c);
        System.assertEquals(5, updatedMap.get(lines[1].Id).Discount__c);
        System.assertEquals(10, updatedMap.get(lines[2].Id).Discount__c);
    }
}
