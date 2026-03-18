/*
How do you prevent a record from being inserted in Salesforce using a trigger?
*/

//Trigger
trigger LeadBeforeInsertTrigger on Lead (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        LeadTriggerHandler.validateLeadBeforeInsert(Trigger.new);
    }
}
//Handler
public class LeadTriggerHandler {

    public static void validateLeadBeforeInsert(List<Lead> newLeads) {
        
        if (newLeads == null || newLeads.isEmpty()) {
            return;
        }
        
        for (Lead leadRec : newLeads) {
            if (leadRec.Title == null) {
                leadRec.addError('Title is required before creating a Lead.');
            }
        }
    }
}

//Test class

@isTest
public class LeadTriggerTest {

    @isTest
    static void testPreventLeadInsertWhenTitleMissing() {
        
        Lead leadRecord = new Lead();
        leadRecord.LastName = 'Test';
        leadRecord.Company = 'TestCompany';
        leadRecord.Salutation = 'Mr.';
        
        Boolean isInserted = false;
        
        try {
            insert leadRecord;
            isInserted = true;   
        } catch (Exception e) {
            System.debug('Insert failed: ' + e.getMessage());
        }
        
        System.assertEquals(
            false, 
            isInserted, 
            'Lead insert should fail when Title is missing'
        );
    }

    @isTest
    static void testLeadInsertSuccessWhenTitlePresent() {
        
        Lead leadRecord = new Lead();
        leadRecord.LastName = 'Test';
        leadRecord.Company = 'TestCompany';
        leadRecord.Title = 'Manager';
        leadRecord.Salutation = 'Mr.';
        
        Boolean isInserted = false;
        
        try {
            insert leadRecord;
            isInserted = true;   
        } catch (Exception e) {
            System.debug('Insert failed: ' + e.getMessage());
        }
        
        System.assertEquals(
            true, 
            isInserted, 
            'Lead should be inserted successfully when Title is provided'
        );
    }
}
