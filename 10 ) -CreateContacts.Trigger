trigger accountTrigger on Account (after insert) {

    List<Contact> conList = new List<Contact>();

    for (Account acc : Trigger.New) {
        for (Integer i = 0; i < 3; i++) {
            conList.add(new Contact(
                LastName = 'Support Contact',
                AccountId = acc.Id
            ));
        }
    }

    if (!conList.isEmpty()) {
        insert conList;
    }
}
/*
Your organization wants to automate the creation of support contacts whenever a new Account is created.
*/
//Test class
@IsTest
public class AccountTriggerSpec {

    @IsTest
    static void shouldCreateSupportContactOnAccountInsert() {

        // Arrange
        Account acc = new Account(
            Name = 'Test Account'
        );

        // Act
        insert acc;

        // Assert
        List<Contact> contacts = [
            SELECT Id, LastName, AccountId
            FROM Contact
            WHERE AccountId = :acc.Id
        ];

        System.assertEquals(
            1,
            contacts.size(),
            'One support contact should be created'
        );

        System.assertEquals(
            'Test Account Support',
            contacts[0].LastName,
            'Contact last name should follow naming convention'
        );
    }
}
