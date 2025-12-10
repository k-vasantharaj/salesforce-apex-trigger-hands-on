trigger CaseTrigger on Case (before delete) {

    // Collect Case IDs being deleted
    Set<Id> caseIds = new Set<Id>();
    for (Case c : Trigger.old) {
        caseIds.add(c.Id);
    }

    if (caseIds.isEmpty()) return;

    // Query approval info
    List<ProcessInstance> pendingApprovals = [
        SELECT Id, TargetObjectId, Status
        FROM ProcessInstance
        WHERE TargetObjectId IN :caseIds
          AND Status = 'Pending'
    ];

    Set<Id> lockedCases = new Set<Id>();
    for (ProcessInstance pi : pendingApprovals) {
        lockedCases.add(pi.TargetObjectId);
    }

    // Block deletion for Cases with pending approval
    for (Case c : Trigger.old) {
        if (lockedCases.contains(c.Id)) {
            c.addError('You cannot delete this Case because it is currently in a pending approval process.');
        }
    }
}
/*
“How do you prevent deletion of a Case record that is currently in a Pending approval process?”
*/
