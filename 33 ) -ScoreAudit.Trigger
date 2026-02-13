trigger LeadTrigger on Lead (after update) {

    List<Lead_Audit__c> auditRecords = new List<Lead_Audit__c>();

    for (Lead newL : Trigger.new) {
        Lead oldL = Trigger.oldMap.get(newL.Id);

        // Check if Score field changed
        if (newL.Score__c != oldL.Score__c) {

            auditRecords.add(new Lead_Audit__c(
                OldValue__c = oldL.Score__c,
                NewValue__c = newL.Score__c,
                LeadId__c = newL.Id,
                UserId__c = UserInfo.getUserId()
            ));
        }
    }

    if (!auditRecords.isEmpty()) {
        insert auditRecords;
    }
}

/*
“When Lead.Score__c changes, create a Lead_Audit__c record logging the old value, new value, Lead Id, and User Id.”
*/

//Test Class

@isTest
public class LeadTriggerTest {

    @isTest
    static void testAuditRecordCreatedOnScoreChange() {

        // Create test Lead
        Lead l = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Lead_Score__c = 10
        );
        insert l;

        Test.startTest();

        // Update score
        l.Lead_Score__c = 20;
        update l;

        Test.stopTest();

        // Fetch audit record
        List<Lead_Audit__c> auditList = [
            SELECT LeadId__c, OldValue__c, NewValue__c, UserId__c
            FROM Lead_Audit__c
            WHERE LeadId__c = :l.Id
        ];

        // Assertions
        System.assertEquals(1, auditList.size(), 'One audit record should be created');
        System.assertEquals(10, auditList[0].OldValue__c, 'Old value should be 10');
        System.assertEquals(20, auditList[0].NewValue__c, 'New value should be 20');
        System.assertEquals(l.Id, auditList[0].LeadId__c, 'Lead Id should match');
        System.assertEquals(UserInfo.getUserId(), auditList[0].UserId__c, 'User Id should match');
    }


    @isTest
    static void testNoAuditRecordWhenScoreNotChanged() {

        Lead l = new Lead(
            LastName = 'No Change Lead',
            Company = 'Test Company',
            Lead_Score__c = 15
        );
        insert l;

        Test.startTest();

        // Update some other field
        l.Company = 'Updated Company';
        update l;

        Test.stopTest();

        List<Lead_Audit__c> auditList = [
            SELECT Id
            FROM Lead_Audit__c
            WHERE LeadId__c = :l.Id
        ];

        System.assertEquals(0, auditList.size(), 'No audit record should be created');
    }
}
