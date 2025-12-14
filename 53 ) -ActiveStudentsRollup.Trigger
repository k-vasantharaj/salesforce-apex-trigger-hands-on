trigger StudentTrigger on Student__c (after insert, after delete) {

    // 1️⃣ Collect Course Ids affected by Student insert or delete
    Set<Id> courseIds = new Set<Id>();

    if (Trigger.isInsert) {
        for (Student__c s : Trigger.new) {
            if (s.Course__c != null) {
                courseIds.add(s.Course__c);
            }
        }
    } else if (Trigger.isDelete) {
        for (Student__c s : Trigger.old) {
            if (s.Course__c != null) {
                courseIds.add(s.Course__c);
            }
        }
    }

    if (courseIds.isEmpty()) return;

    // 2️⃣ Aggregate query: count active students per course
    Map<Id, Integer> studentCountMap = new Map<Id, Integer>();

    for (AggregateResult ar : [
        SELECT Course__c cId, COUNT(Id) studentCount
        FROM Student__c
        WHERE Course__c IN :courseIds
        GROUP BY Course__c
    ]) {
        studentCountMap.put((Id) ar.get('cId'), (Integer) ar.get('studentCount'));
    }

    // 3️⃣ Prepare Course records to update
    List<Course__c> coursesToUpdate = new List<Course__c>();

    for (Id cId : courseIds) {
        coursesToUpdate.add(new Course__c(
            Id = cId,
            Active_Students__c = studentCountMap.containsKey(cId) 
                                 ? studentCountMap.get(cId) 
                                 : 0
        ));
    }

    // 4️⃣ Update Courses
    if (!coursesToUpdate.isEmpty()) {
        update coursesToUpdate;
    }
}
/*
How to automatically update a Course’s Active_Students__c field whenever Student__c records are inserted or deleted, in a bulk-safe way?
*/
