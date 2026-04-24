//Question 
Block Account delete if it has related Opportunities.

//Trigger
trigger AccountTrigger on Account (before delete ) {

    if(Trigger.isbefore && Trigger.isDelete)
    {
        TriggerHandler.beforeDeleteOperation(Trigger.old);
    }
}

//Handler

public class TriggerHandler {

    public static void beforeDeleteOperation(List<Account> deletedAccounts) 
    {
        if(deletedAccounts == null || deletedAccounts.isEmpty()) return;
        
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : deletedAccounts)
        {
            if(acc.Id != null)
            {
                accountIds.add(acc.Id);
            }
        }
        
        Set<Id> accountRelatedToOpps = new Set<Id>();
        for(Opportunity opp: [SELECT AccountId, Id 
                              FROM Opportunity 
                              WHERE AccountId IN :accountIds])
        {
            accountRelatedToOpps.add(opp.AccountId);
        }
        
        for(Account acc : deletedAccounts)
        {
            if(acc.Id != null && accountRelatedToOpps.contains(acc.Id))
            {
                acc.addError('Block Account delete if it has related Opportunities.');
            }
        }
    }
}

//Test class

@isTest
public class testDemo {

    @isTest
    static void deleteAccountWithoutOpportunity()
    {
       Account acc1 = new Account(Name = 'acc1');
       insert acc1;
        
       Account acc2 = new Account(Name = 'acc2');
       insert acc2;
        
       Opportunity opp = new Opportunity(
           Name = 'opp1',
           AccountId = acc2.Id,
           StageName = 'Prospecting',
           CloseDate = System.today().addDays(10)
       );
       insert opp;

       delete acc1;
        
       List<Account> accList = [SELECT Id FROM Account WHERE Id = :acc1.Id];
       System.assertEquals(0, accList.size(), 'account must be deleted'); 
    }

    @isTest
    static void deleteAccountWithOpportunity()
    {
       Account acc2 = new Account(Name = 'acc2');
       insert acc2;
        
       Opportunity opp = new Opportunity(
           Name = 'opp1',
           AccountId = acc2.Id,
           StageName = 'Prospecting',
           CloseDate = System.today().addDays(10)
       );
       insert opp;

       Boolean isExceptionThrown = false;
        
        try
        {
            delete acc2;
        }
        catch(Exception e)
        {
            isExceptionThrown = true;            
        }

        System.assertEquals(true, isExceptionThrown,
            'Block Account delete if it has related Opportunities.');
    }
}
