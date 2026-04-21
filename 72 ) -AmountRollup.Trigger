//Question

You have Opportunity and OpportunityLineItem.

Question:
Update a custom field Total_Amount__c on Opportunity which stores the sum of all OpportunityLineItem TotalPrice.

//Trigger

trigger OpportunityLineItemTrigger on OpportunityLineItem 
(after insert, after update, after delete, after undelete) {

    Set<Id> oppIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        oppIds = OpportunityLineItemTriggerHandler.getOpportunityIds(Trigger.new);
    }

    if (Trigger.isDelete) {
        oppIds = OpportunityLineItemTriggerHandler.getOpportunityIds(Trigger.old);
    }

    OpportunityLineItemTriggerHandler.updateOpportunityTotalAmount(oppIds);
}

//Handler

public class OpportunityLineItemTriggerHandler {

    public static void updateOpportunityTotalAmount(Set<Id> oppIds) {

        if (oppIds == null || oppIds.isEmpty()) return;

        Map<Id, Decimal> oppAmountMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT OpportunityId oppId, SUM(TotalPrice) total
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
            GROUP BY OpportunityId
        ]) {
            oppAmountMap.put(
                (Id) ar.get('oppId'),
                (Decimal) ar.get('total')
            );
        }

        List<Opportunity> oppToUpdate = new List<Opportunity>();

        for (Id oppId : oppIds) {
            oppToUpdate.add(new Opportunity(
                Id = oppId,
                Total_Amount__c = oppAmountMap.containsKey(oppId)
                    ? oppAmountMap.get(oppId)
                    : 0
            ));
        }

        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
    }

    public static Set<Id> getOpportunityIds(List<OpportunityLineItem> records) {
        Set<Id> oppIds = new Set<Id>();

        for (OpportunityLineItem oli : records) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }

        return oppIds;
    }
}
