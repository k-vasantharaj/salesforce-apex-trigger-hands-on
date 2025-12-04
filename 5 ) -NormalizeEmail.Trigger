trigger contactTrigger on Contact (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

        for (Contact con : Trigger.new) {
            if (con.Email != null) {

                // Convert to lowercase + remove spaces
                con.Email = con.Email
                            .toLowerCase()
                            .trim()
                            .deleteWhitespace();
            }
        }
    }
}
