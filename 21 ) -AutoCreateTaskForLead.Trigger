trigger LeadTrigger on Lead (after insert) {

    List<Task> taskList = new List<Task>();

    for (Lead ld : Trigger.new) {
        if (ld.Status == 'Open - Not Contacted') {
            taskList.add(new Task(
                OwnerId = ld.OwnerId,
                WhoId = ld.Id,
                Subject = 'Follow-Up with Lead',
                Priority = 'Normal',
                Status = 'Not Started'
            ));
        }
    }

    if (!taskList.isEmpty()) {
        insert taskList;
    }
}
/*
On Lead creation, if Status = "Open - Not Contacted", automatically create a Task assigned to the Lead Owner. Write the trigger using best practices.

*/
