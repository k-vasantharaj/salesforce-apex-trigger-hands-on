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
//Test class

@isTest
public class testDemo {

    @isTest
    static void checkIsUpdated()
    {
        Account acc = new Account();
        acc.Name = 'acc1';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name ='opp1';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today().addDays(10);
        opp.StageName = 'Prospecting';
        opp.Amount = 5000;
        insert opp;
        
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        
        Account updatedAccount = [
            SELECT Id, Total_Won_Amount__c 
            FROM Account 
            WHERE Id = :acc.Id
        ];
        
        System.assertEquals(5000, updatedAccount.Total_Won_Amount__c, 'must be same');          
    }
}
