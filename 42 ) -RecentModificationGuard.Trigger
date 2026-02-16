trigger AccountTrigger on Account (before delete) {

    DateTime currentTime = DateTime.now();
    DateTime last24Hours = currentTime.addHours(-24);

    for (Account acc : Trigger.old) {
        // Check if the record was modified within the last 24 hours
        if (acc.LastModifiedDate > last24Hours) {
            acc.addError('You cannot delete this Account because it was modified in the last 24 hours.');
        }
    }
}
/*
“How would you prevent deletion of an Account record if it was modified in the last 24 hours?”
*/

//Test class

@isTest
public class AccountTriggerTest {

    // ---- Test: deletion should be blocked if modified recently ----
    @isTest
    static void shouldPreventDeleteWhenModifiedWithin24Hours() {

        // Arrange
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Modify record (now LastModifiedDate is recent)
        acc.Name = 'Updated Name';
        update acc;

        Boolean isBlocked = false;

        Test.startTest();
        try {
            delete acc;
        } catch (DmlException ex) {
            isBlocked = true;
        }
        Test.stopTest();

        // Assert
        System.assert(isBlocked,
            'Deletion must be blocked if record was modified within last 24 hours');
    }


    // ---- Test: deletion allowed if never modified after insert ----
    @isTest
    static void shouldAllowDeleteWhenNotModified() {

        // Arrange
        Account acc = new Account(Name = 'Old Account');
        insert acc;

        Boolean isBlocked = false;

        Test.startTest();
        try {
            delete acc;
        } catch (DmlException ex) {
            isBlocked = true;
        }
        Test.stopTest();

        // Assert
        System.assertEquals(false, isBlocked,
            'Deletion should be allowed when record is older than restriction window');
    }
}
