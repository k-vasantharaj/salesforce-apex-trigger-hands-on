trigger ContactTrigger on Contact (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Contact con : Trigger.new) {

            if (String.isNotBlank(con.Phone)) {

                // Remove all non-numeric characters
                String cleanedPhone = con.Phone.replaceAll('[^0-9]', '');

                // If number has exactly 10 digits -> auto add +91
                if (cleanedPhone.length() == 10) {
                    con.Phone = '+91' + cleanedPhone;
                } else {
                    con.Phone = cleanedPhone;
                }
            }
        }
    }
}
