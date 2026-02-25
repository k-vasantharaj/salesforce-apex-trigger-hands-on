trigger AccountTrigger on Account (after update) {

    /*
     * Requirement:
     * Account has a custom field Active_Case_Count__c.
     * This should reflect the number of related Cases with Status != 'Closed'.
     */

    // Step 1: Collect Account IDs for processing
    Set<Id> accountIds = new Set<Id>();

    for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        // Optional: Detect specific field changes; 
        // here we process all updates for simplicity
        accountIds.add(acc.Id);
    }

    if (accountIds.isEmpty()) return;

    // Step 2: Aggregate Cases by Account
    Map<Id, Integer> caseCountMap = new Map<Id, Integer>();

    for (AggregateResult ar : [
        SELECT AccountId accId, COUNT(Id) statusCount
        FROM Case
        WHERE AccountId IN :accountIds
          AND Status != 'Closed'
        GROUP BY AccountId
    ]) {
        caseCountMap.put(
            (Id) ar.get('accId'),
            (Integer) ar.get('statusCount')
        );
    }

    // Step 3: Prepare Account records for update
    List<Account> accountsToUpdate = new List<Account>();

    for (Id accId : accountIds) {
        accountsToUpdate.add(new Account(
            Id = accId,
            Active_Case_Count__c = caseCountMap.containsKey(accId) 
                ? caseCountMap.get(accId) 
                : 0
        ));
    }

    // Step 4: Update Accounts
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
/*
Write a bulkified after-update Apex trigger on Account that updates a custom field Active_Case_Count__c.
This field should store the number of related Case records where Status ≠ 'Closed'.
*/


//Test class

@IsTest
public class AccountCaseCountHandlerTest {

    @IsTest
    static void shouldUpdateActiveCaseCountAfterAccountUpdate() {

        // Step 1 : Create test Accounts
        Account accOne = new Account(Name = 'Account One');
        Account accTwo = new Account(Name = 'Account Two');

        insert new List<Account>{ accOne, accTwo };

        // Step 2 : Create related Cases
        List<Case> testCases = new List<Case>{
            // accOne -> 2 active + 1 closed
            new Case(AccountId = accOne.Id, Status = 'New',     Origin = 'Phone'),
            new Case(AccountId = accOne.Id, Status = 'Working', Origin = 'Email'),
            new Case(AccountId = accOne.Id, Status = 'Closed',  Origin = 'Web'),

            // accTwo -> 1 active
            new Case(AccountId = accTwo.Id, Status = 'New',     Origin = 'Phone')
        };

        insert testCases;

        // Step 3 : Update Accounts to fire AFTER UPDATE trigger
        Test.startTest();

        accOne.Description = 'Trigger execution';
        accTwo.Description = 'Trigger execution';
        update new List<Account>{ accOne, accTwo };

        Test.stopTest();

        // Step 4 : Verify results
        Map<Id, Account> updatedAccounts = new Map<Id, Account>([
            SELECT Active_Case_Count__c
            FROM Account
            WHERE Id IN :new List<Id>{ accOne.Id, accTwo.Id }
        ]);

        System.assertEquals(
            2,
            updatedAccounts.get(accOne.Id).Active_Case_Count__c,
            'Account One should have two active cases'
        );

        System.assertEquals(
            1,
            updatedAccounts.get(accTwo.Id).Active_Case_Count__c,
            'Account Two should have one active case'
        );
    }
}
