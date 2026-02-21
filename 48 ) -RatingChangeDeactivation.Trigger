/*
When an Account record is updated, if the Rating changes from Hot to Cold and AnnualRevenue is blank, the Active__c field must be automatically set to 'No'.
*/

//trigger 

trigger AccountTrigger on Account (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        AccountTriggerHandler.handleBeforeUpdate(
            Trigger.new,
            Trigger.oldMap
        );
    }
}

//TriggerHandler

public class AccountTriggerHandler {

    /*
     * When an Account record is updated,
     * if the Rating changes from 'Hot' to 'Cold'
     * and AnnualRevenue is blank,
     * then set Active__c to 'No'.
     */
    public static void handleBeforeUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldAccountMap
    ) {

        for (Account newAcc : newAccounts) {

            Account oldAcc = oldAccountMap.get(newAcc.Id);

            if (oldAcc == null) {
                continue;
            }

            if (
                oldAcc.Rating == 'Hot' &&
                newAcc.Rating == 'Cold' &&
                newAcc.AnnualRevenue == null
            ) {
                newAcc.Active__c = 'No';
            }
        }
    }
}



//Test class

@IsTest
public class AccountRatingHotToColdActiveUpdateTest {

    @IsTest
    static void testAccountRatingChangeFromHotToColdSetsActiveNo() {

        // Arrange
        Account acc = new Account(
            Name = 'Test Account',
            Rating = 'Hot'
            // AnnualRevenue intentionally left blank
        );
        insert acc;

        // Act
        acc.Rating = 'Cold';

        Test.startTest();
        update acc;
        Test.stopTest();

        // Assert
        Account updatedAcc = [
            SELECT Active__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            'No',
            updatedAcc.Active__c,
            'Active__c should be set to No when Rating changes from Hot to Cold and AnnualRevenue is blank.'
        );
    }
}
