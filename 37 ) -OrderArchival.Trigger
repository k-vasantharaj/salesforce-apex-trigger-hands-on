trigger OrderTrigger on Order__c (before delete) {

    // Collect all Order IDs being deleted
    Set<Id> orderIds = new Set<Id>();
    for (Order__c ord : Trigger.old) {
        orderIds.add(ord.Id);
    }

    if (orderIds.isEmpty()) return;

    // Query related Order Items
    List<Order_Items__c> itemsToArchive = [
        SELECT Id, Is_Archived__c
        FROM Order_Items__c
        WHERE Order__c IN :orderIds
          AND Is_Archived__c = false
    ];

    // Mark items as archived
    for (Order_Items__c item : itemsToArchive) {
        item.Is_Archived__c = true;
    }

    // Update in before context (this is allowed because these are children, not the records being deleted)
    if (!itemsToArchive.isEmpty()) {
        update itemsToArchive;
    }
}

/*
“How would you design a trigger to ensure that when an Order__c record is deleted, 
all related Order_Items__c records are marked as Is_Archived__c = true, 
while avoiding recursion and avoiding DML on the records being deleted?”
*/
