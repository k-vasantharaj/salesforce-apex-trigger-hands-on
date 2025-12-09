trigger AccountTrigger on Account (before insert) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        
        // Collect unique names from incoming records
        Set<String> incomingNames = new Set<String>();
        for (Account acc : Trigger.new) {
            if (acc.Name != null) {
                incomingNames.add(acc.Name.toLowerCase());
            }
        }

        // Query existing accounts with same names
        Set<String> existingNames = new Set<String>();
        for (Account acc : [
            SELECT Name FROM Account 
            WHERE Name IN :incomingNames
        ]) {
            existingNames.add(acc.Name.toLowerCase());
        }

        // Check for duplicates
        for (Account acc : Trigger.new) {
            if (acc.Name != null && existingNames.contains(acc.Name.toLowerCase())) {
                acc.addError('Duplicate Account Name Found! Please use a different name.');
            }
        }
    }
}
/*
When inserting an Account, 
prevent creation if another Account with the same name already exists by showing an error for duplicate names.
*/
