/*
Implement a trigger on Lead such that when a Lead record is updated and its Status changes to "Qualified", 
the field Ready_for_Conversion__c is automatically set to true.
Ensure that the logic executes only when the Status value actually changes and follows bulk-safe best practices.
*/

//Trigger
trigger LeadTrigger on Lead (before update) {

    if(Trigger.isBefore && Trigger.isUpdate)
    {
        LeadConversionHandler.handleStatusChange(Trigger.new, Trigger.oldMap);
    }

}

//Handler
public class LeadConversionHandler 
{   
    public static void handleStatusChange(List<Lead> newLeads, Map<Id, Lead> oldMap){
        
        for(Lead newLead : newLeads)
        {
            Lead oldLead = oldMap.get(newLead.Id);
            
            if(newLead.Status != oldLead.Status && newLead.Status == 'Qualified')
            {
                newLead.Ready_for_Conversion__c = true;
            }
        }
    }
}

//Test class
@isTest
public class LeadConversionHandlerTest {

    @isTest
    static void testLeadQualifiedConversionFlag() {

        // Step 1: Create test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Salutation = 'Mr.',
            Status = 'Working - Contacted'
        );
        insert testLead;

        // Step 2: Update Status to Qualified
        Test.startTest();
        testLead.Status = 'Qualified';
        update testLead;
        Test.stopTest();

        // Step 3: Verify result
        Lead updatedLead = [
            SELECT Id, Status, Ready_for_Conversion__c
            FROM Lead
            WHERE Id = :testLead.Id
        ];

        System.assertEquals(
            true,
            updatedLead.Ready_for_Conversion__c,
            'Ready_for_Conversion__c should be true when status changes to Qualified'
        );
    }

      @isTest
static void testStatusNotChanged() {

    Lead testLead = new Lead(
        LastName = 'Test Lead',
        Company = 'Test Company',
        Status = 'Working - Contacted'
    );
    insert testLead;

    Test.startTest();
    testLead.Company = 'Updated Company'; // No status change
    update testLead;
    Test.stopTest();

    Lead updatedLead = [
        SELECT Ready_for_Conversion__c
        FROM Lead
        WHERE Id = :testLead.Id
    ];

    System.assertEquals(
        false,
        updatedLead.Ready_for_Conversion__c,
        'Field should remain false when status is not changed to Qualified'
    );
  }
}
