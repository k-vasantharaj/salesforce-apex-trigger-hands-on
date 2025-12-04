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
