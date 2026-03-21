/*
 Lead Validation Logic

When a Lead is inserted or updated, implement the following:

If Lead Source field is blank, prevent the record from being saved
If Email is provided, it must contain @ 
If Phone is provided, it must be exactly 10 digits
Show appropriate error messages on respective fields

*/

//Trigger 
trigger LeadValidationTrigger on Lead (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LeadValidationHandler.validateLeadData(Trigger.new);
    }

}
//

public class LeadValidationHandler {

    public static void validateLeadData(List<Lead> leadList) {

        if (leadList == null || leadList.isEmpty()) {
            return;
        }

        for (Lead leadRecord : leadList) {

            // Validate Lead Source
            if (String.isBlank(leadRecord.LeadSource)) {
                leadRecord.LeadSource.addError('Lead Source cannot be empty.');
            }

            // Validate Email
            if (!String.isBlank(leadRecord.Email) && !isValidEmail(leadRecord.Email)) {
                leadRecord.Email.addError('Please enter a valid email address.');
            }

            // Validate Phone
            if (!String.isBlank(leadRecord.Phone) && !isValidPhone(leadRecord.Phone)) {
                leadRecord.Phone.addError('Phone number must be exactly 10 digits.');
            }
        }
    }

    // Helper method to validate email format
    private static Boolean isValidEmail(String email) {
        return email.contains('@') && email.contains('.');
    }

    // Helper method to validate phone number
    private static Boolean isValidPhone(String phone) {
        String digitsOnly = phone.replaceAll('[^0-9]', '');
        return digitsOnly.length() == 10;
    }
}

//Test class

@isTest
public class LeadValidationHandlerTest {

    @isTest
    static void testValidLeadInsert() {
        Lead validLead = new Lead(
            LastName = 'Test',
            Company = 'ABC Corp',
            LeadSource = 'Web',
            Email = 'test@example.com',
            Phone = '9876543210'
        );

        Test.startTest();
        insert validLead;
        Test.stopTest();

        System.assertNotEquals(null, validLead.Id, 'Lead should be inserted successfully');
    }

    @isTest
    static void testMissingLeadSource() {
        Lead invalidLead = new Lead(
            LastName = 'Test',
            Company = 'ABC Corp'
        );

        Test.startTest();
        try {
            insert invalidLead;
            System.assert(false, 'Expected error for missing Lead Source');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Lead Source cannot be empty'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidEmail() {
        Lead invalidLead = new Lead(
            LastName = 'Test',
            Company = 'ABC Corp',
            LeadSource = 'Web',
            Email = 'invalidemail'
        );

        Test.startTest();
        try {
            insert invalidLead;
            System.assert(false, 'Expected error for invalid email');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('valid email'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidPhone() {
        Lead invalidLead = new Lead(
            LastName = 'Test',
            Company = 'ABC Corp',
            LeadSource = 'Web',
            Phone = '12345'
        );

        Test.startTest();
        try {
            insert invalidLead;
            System.assert(false, 'Expected error for invalid phone');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('10 digits'));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateValidation() {
        Lead leadRec = new Lead(
            LastName = 'Test',
            Company = 'ABC Corp',
            LeadSource = 'Web'
        );
        insert leadRec;

        leadRec.Email = 'wrongEmail';

        Test.startTest();
        try {
            update leadRec;
            System.assert(false, 'Expected error on update');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('valid email'));
        }
        Test.stopTest();
    }
}
