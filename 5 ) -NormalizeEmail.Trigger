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
/*
To improve data quality and ensure consistency across the system, your organization has mandated that all Contact email addresses must be stored in a standardized format. Users might enter email values with uppercase letters or additional spaces.
*/
