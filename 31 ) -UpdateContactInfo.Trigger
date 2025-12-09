trigger contactTrigger on Contact (after update) {

    Set<Id> accIds = new Set<Id>();

    for(Contact con : Trigger.new)
    {
        Contact oldCon = Trigger.oldMap.get(con.Id);

        // Check if Account exists and ANY tracked field changed
        if(oldCon.AccountId != null &&
          (con.Email != oldCon.Email ||
           con.Phone != oldCon.Phone ||
           con.Title != oldCon.Title))
        {
            accIds.add(con.AccountId);
        }
    }

    if(!accIds.isEmpty())
    {
        List<Account> accList = [
            SELECT Id, Last_Contact_Update__c
            FROM Account
            WHERE Id IN :accIds
        ];

        for(Account acc : accList)
        {
            acc.Last_Contact_Update__c = System.today();
        }

        update accList;
    }
}

/*
     * When a Contact’s Email OR Phone OR Title is updated, Update Account.Last_Contact_Update__c = System.today() for the related Account
     
     */
