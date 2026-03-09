/*Create an Apex Trigger on Opportunity.

Whenever an Opportunity is updated calculate the total Amount of all Opportunities where Stage = 'Closed Won' for each Account.

Update the total in the Account field Total_Won_Amount__c.
*/
//Trigger
trigger OpportunityTrigger on Opportunity (after update) {


    if(Trigger.isAfter && Trigger.isUpdate)
       {
            TriggerHandler.updatingTotalAmount(Trigger.new );
       }

    
}

//Handler

public class TriggerHandler 
{   
/*
Whenever an Opportunity is inserted
calculate the total Amount of all Opportunities where Stage = 'Closed Won' for each Account.
Update the total in the Account field Total_Won_Amount__c.
*/
      
    Public static void updatingTotalAmount(List<Opportunity> updatedOpps ){
        
        if(updatedOpps.isEmpty()) return;
        
        Set<Id> accIds = new Set<Id>();
        
        for(Opportunity opp :updatedOpps)
        {
            if(opp.AccountId != NULL)
            {
                accIds.add(opp.AccountId);
            }
        }
        
        Map<Id,Decimal> accMap = new Map<Id,Decimal>();
        
        for(AggregateResult ar :[
                                  SELECT AccountId acId , SUM(Amount) totalAmount
                                  FROM
                                  Opportunity 
                                  WHERE AccountId In:accIds
                                  AND StageName = 'Closed Won'
                                  GROUP BY AccountId                          
        ])
        {
            accMap.put(
            (Id)ar.get('acId'),
            (Decimal)ar.get('totalAmount')    
            );
        }
        
        List<Account> accToUpdate = new List<Account>();
        
        for(Id acId :accIds)
        {
            Account acc = new Account();
            acc.id = acId;
            acc.Total_Won_Amount__c = accMap.containsKey(acId) ? accMap.get(acId) : 0;
            accToUpdate.add(acc);
        }
        
        if(!accToUpdate.isEmpty())
        {
            update accToUpdate;
        }
        
    }
        

       
    
    
}
