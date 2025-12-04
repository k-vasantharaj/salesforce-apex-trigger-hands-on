trigger LeadTrigger on Lead (after insert) {

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Lead leadRecord : Trigger.new) {

        if (leadRecord.Owner.Email != null) {

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ leadRecord.Owner.Email });
            email.setSubject('New Lead Created: ' + leadRecord.Name);
            email.setPlainTextBody(
                'A new Lead has been created.\n\n' +
                'Lead Name: ' + leadRecord.Name + '\n' +
                'Company: ' + leadRecord.Company + '\n' +
                'Status: ' + leadRecord.Status
            );

            emails.add(email);
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}
