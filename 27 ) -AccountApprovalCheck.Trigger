trigger OpportunityTrigger on Opportunity (before update) {

    // Step 1: Collect AccountIds that are being changed
    Set<Id> changedAccountIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if (opp.AccountId != oldOpp.AccountId && opp.AccountId != null) {
            changedAccountIds.add(opp.AccountId);
        }
    }

    // Step 2: Query Accounts that are NOT approved
    Map<Id, Boolean> accountApprovalMap = new Map<Id, Boolean>();
    if (!changedAccountIds.isEmpty()) {
        for (Account acc : [
            SELECT Id, Is_Approved__c
            FROM Account
            WHERE Id IN :changedAccountIds
        ]) {
            accountApprovalMap.put(acc.Id, acc.Is_Approved__c);
        }
    }

    // Step 3: Block Opportunity update if new Account is not approved
    for (Opportunity opp : Trigger.new) {
        if (opp.AccountId != null &&
            accountApprovalMap.containsKey(opp.AccountId) &&
            accountApprovalMap.get(opp.AccountId) == false) {
            
            opp.addError('Account change blocked: The selected Account is not approved.');
        }
    }
}


    /*
How can you prevent an Opportunity from being reassigned to an Account that is not approved when the AccountId is changed during an update?
     */

//Test class

@isTest
private class OpportunityTriggerTest {

    @testSetup
    static void setupTestData() {

        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Approved Account 1',
                Is_Approved__c = true
            ),
            new Account(
                Name = 'Approved Account 2',
                Is_Approved__c = true
            ),
            new Account(
                Name = 'Unapproved Account',
                Is_Approved__c = false
            )
        };

        insert accounts;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accounts[0].Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );

        insert opp;
    }


    @isTest
    static void testUpdateFailsWhenAccountIsUnapproved() {

        Opportunity existingOpportunity = [
            SELECT Id, AccountId
            FROM Opportunity
            LIMIT 1
        ];

        Account unapprovedAccount = [
            SELECT Id
            FROM Account
            WHERE Is_Approved__c = false
            LIMIT 1
        ];

        Test.startTest();
        Boolean isExceptionThrown = false;

        try {
            existingOpportunity.AccountId = unapprovedAccount.Id;
            update existingOpportunity;
        } catch (DmlException ex) {
            isExceptionThrown = true;
        }

        Test.stopTest();

        System.assert(
            isExceptionThrown,
            'Opportunity update must fail when linked Account is not approved.'
        );
    }


    @isTest
    static void testUpdateSucceedsWhenAccountIsApproved() {

        Opportunity existingOpportunity = [
            SELECT Id, AccountId
            FROM Opportunity
            LIMIT 1
        ];

        Account approvedAccount = [
            SELECT Id
            FROM Account
            WHERE Is_Approved__c = true
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Test.startTest();
        existingOpportunity.AccountId = approvedAccount.Id;
        update existingOpportunity;
        Test.stopTest();

        Opportunity updatedOpportunity = [
            SELECT AccountId
            FROM Opportunity
            WHERE Id = :existingOpportunity.Id
        ];

        System.assertEquals(
            approvedAccount.Id,
            updatedOpportunity.AccountId,
            'Opportunity should update successfully when Account is approved.'
        );
    }
}
