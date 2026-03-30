//Question
Opportunity Amount Rollup (Manual)

When Opportunity is inserted, updated, deleted, or undeleted:

Calculate total Amount of all Closed Won Opportunities per Account
Store the total in Account.Total_Revenue__c
Handle all trigger events properly

//Trigger
trigger OpportunityTrigger on Opportunity (
    after insert, 
    after update, 
    after delete, 
    after undelete
) {

    if(Trigger.isAfter){

        if(Trigger.isInsert){
            OpportunityRevenueHandler.updateRevenueOnInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            OpportunityRevenueHandler.updateRevenueOnUpdate(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isDelete){
            OpportunityRevenueHandler.updateRevenueOnDelete(Trigger.old);
        }

        if(Trigger.isUndelete){
            OpportunityRevenueHandler.updateRevenueOnUndelete(Trigger.new);
        }
    }
}


//Trigger Handler
public class OpportunityRevenueHandler {

    public static void updateRevenueOnInsert(List<Opportunity> oppList) {

        if(oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : oppList){
            if(opp.AccountId != null && opp.StageName == 'Closed Won'){
                accIds.add(opp.AccountId);
            }
        }

        if(accIds.isEmpty()) return;

        Map<Id, Decimal> accRevenueMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) totalAmt
            FROM Opportunity
            WHERE AccountId IN :accIds
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]){
            accRevenueMap.put((Id)ar.get('accId'), (Decimal)ar.get('totalAmt'));
        }

        List<Account> accList = new List<Account>();

        for(Id accId : accIds){
            accList.add(new Account(
                Id = accId,
                Total_Revenue__c = accRevenueMap.containsKey(accId) ? accRevenueMap.get(accId) : 0
            ));
        }

        if(!accList.isEmpty()){
            update accList;
        }
    }


    public static void updateRevenueOnUpdate(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {

        if(oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : oppList){

            Opportunity oldOpp = oldMap.get(opp.Id);
            if(oldOpp == null || opp.AccountId == null) continue;

            if(oldOpp.StageName != opp.StageName){
                accIds.add(opp.AccountId);
            }
        }

        if(accIds.isEmpty()) return;

        Map<Id, Decimal> accRevenueMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) totalAmt
            FROM Opportunity
            WHERE AccountId IN :accIds
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]){
            accRevenueMap.put((Id)ar.get('accId'), (Decimal)ar.get('totalAmt'));
        }

        List<Account> accList = new List<Account>();

        for(Id accId : accIds){
            accList.add(new Account(
                Id = accId,
                Total_Revenue__c = accRevenueMap.containsKey(accId) ? accRevenueMap.get(accId) : 0
            ));
        }

        if(!accList.isEmpty()){
            update accList;
        }
    }


    public static void updateRevenueOnDelete(List<Opportunity> oppList) {

        if(oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accIds.add(opp.AccountId);
            }
        }

        if(accIds.isEmpty()) return;

        Map<Id, Decimal> accRevenueMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) totalAmt
            FROM Opportunity
            WHERE AccountId IN :accIds
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]){
            accRevenueMap.put((Id)ar.get('accId'), (Decimal)ar.get('totalAmt'));
        }

        List<Account> accList = new List<Account>();

        for(Id accId : accIds){
            accList.add(new Account(
                Id = accId,
                Total_Revenue__c = accRevenueMap.containsKey(accId) ? accRevenueMap.get(accId) : 0
            ));
        }

        if(!accList.isEmpty()){
            update accList;
        }
    }
}

public static void updateRevenueOnUndelete(List<Opportunity> oppList) {

    if(oppList == null || oppList.isEmpty()) return;

    Set<Id> accIds = new Set<Id>();

    for(Opportunity opp : oppList){
        if(opp.AccountId != null){
            accIds.add(opp.AccountId);
        }
    }

    if(accIds.isEmpty()) return;

    Map<Id, Decimal> accRevenueMap = new Map<Id, Decimal>();

    for(AggregateResult ar : [
        SELECT AccountId accId, SUM(Amount) totalAmt
        FROM Opportunity
        WHERE AccountId IN :accIds
        AND StageName = 'Closed Won'
        GROUP BY AccountId
    ]){
        accRevenueMap.put((Id)ar.get('accId'), (Decimal)ar.get('totalAmt'));
    }

    List<Account> accList = new List<Account>();

    for(Id accId : accIds){
        accList.add(new Account(
            Id = accId,
            Total_Revenue__c = accRevenueMap.containsKey(accId) 
                ? accRevenueMap.get(accId) 
                : 0
        ));
    }

    if(!accList.isEmpty()){
        update accList;
    }
}

//Test class
@isTest
public class OpportunityRevenueHandlerTest {

    @isTest
    static void testAfterInsert() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunities
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(
                Name = 'Opp 1',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 1000,
                AccountId = acc.Id
            ),
            new Opportunity(
                Name = 'Opp 2',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 500,
                AccountId = acc.Id
            )
        };

        Test.startTest();
        insert opps;
        OpportunityRevenueHandler.handleAfterInsert(opps);
        Test.stopTest();

        // Verify
        Account updatedAcc = [SELECT Total_Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1000, updatedAcc.Total_Revenue__c);
    }

    @isTest
    static void testAfterUpdate() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity (not Closed Won)
        Opportunity opp = new Opportunity(
            Name = 'Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 2000,
            AccountId = acc.Id
        );
        insert opp;

        // Update to Closed Won
        opp.StageName = 'Closed Won';

        Test.startTest();
        update opp;
        OpportunityRevenueHandler.handleAfterUpdate(
            new List<Opportunity>{opp},
            new Map<Id, Opportunity>{opp.Id => new Opportunity(Id = opp.Id, StageName = 'Prospecting')}
        );
        Test.stopTest();

        // Verify
        Account updatedAcc = [SELECT Total_Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(2000, updatedAcc.Total_Revenue__c);
    }

    @isTest
    static void testAfterDelete() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Closed Won Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Opp',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 1500,
            AccountId = acc.Id
        );
        insert opp;

        // Ensure initial rollup
        OpportunityRevenueHandler.handleAfterInsert(new List<Opportunity>{opp});

        // Delete Opportunity
        Test.startTest();
        delete opp;
        OpportunityRevenueHandler.handleAfterDelete(new List<Opportunity>{opp});
        Test.stopTest();

        // Verify
        Account updatedAcc = [SELECT Total_Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, updatedAcc.Total_Revenue__c);
    }

    @isTest
    static void testMultipleOpportunitiesAggregation() {
        Account acc = new Account(Name = 'Bulk Test Account');
        insert acc;

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name='Opp1', StageName='Closed Won', CloseDate=Date.today(), Amount=100, AccountId=acc.Id),
            new Opportunity(Name='Opp2', StageName='Closed Won', CloseDate=Date.today(), Amount=200, AccountId=acc.Id),
            new Opportunity(Name='Opp3', StageName='Closed Won', CloseDate=Date.today(), Amount=300, AccountId=acc.Id)
        };

        Test.startTest();
        insert opps;
        OpportunityRevenueHandler.handleAfterInsert(opps);
        Test.stopTest();

        Account updatedAcc = [SELECT Total_Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(600, updatedAcc.Total_Revenue__c);
    }
}
