public class TaskTriggerHandler {

public static void beforeInsert(List<Task> taskList){
    checkTaskData(taskList, null);
}

public static void beforeUpdate(List<Task> newTasks, Map<Id, Task> oldRecordsMap){
    checkTaskData(newTasks, oldRecordsMap);
    

}

public static void beforeDelete(List<Task> oldTasks){
    checkTaskData(oldTasks, null);
}

                
public static void checkTaskData(List<Task> taskList, Map<Id, Task> oldRecordsMap) {
    //List<Task> taskObj11 = new List<Task>();
    Set<Id> idst = new Set<Id>();
    

    Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RecordType2').getRecordTypeId();
    if(Trigger.isInsert || Trigger.isDelete){
        if(!taskList.isEmpty()){
            for(Task task : taskList){
                //Account a = [select id from account where id =: task.AccountId];
                System.debug('task  '+task);
                System.debug('task owner--'+ task.OwnerId);         
                System.debug('Task AccountId '+task.AccountId);
                System.debug('task acc owner--'+ task.Account.OwnerId);
                if(task.OwnerId == task.Account.OwnerId){
                    System.debug('Owners matched');
                    Id accId = task.AccountId;
                    //if(accId.getSobjecttype() == Schema.Account.getSobjecttype()){
                    if(task.Subject == 'Call' || task.Subject == 'Email' || task.Subject == 'Send Letter'){
                        idst.add(accId);
                    }
                    //}
                }
                
            }
            System.debug('idst '+idst);
            System.debug('idst '+idst.size());
        }
    }
    if(Trigger.isUpdate){
        System.debug('upadteTrigger ');
        if(!taskList.isEmpty()){
            System.debug('taskList '+taskList);
            for(Task taskObj : taskList){
                if(taskObj.OwnerId == taskObj.Account.OwnerId){
                    System.debug('Owners matched');
                }
                if(taskObj.AccountId != oldRecordsMap.get(taskObj.Id).AccountId || taskObj.OwnerId != oldRecordsMap.get(taskObj.Id).OwnerId || taskObj.ActivityDate != oldRecordsMap.get(taskObj.Id).ActivityDate){
                    System.debug('In First If Condition');
                    Id accId = taskObj.AccountId;
                  if(accId.getSobjecttype() == Schema.Account.getSobjecttype()){
                    if(taskObj.Subject == 'Call' || taskObj.Subject == 'Email' || taskObj.Subject == 'Send Letter'){
                        
                    idst.add(accId);
                    }
                  }
                }
            }
            System.debug('idst '+idst);
        }
    }

    
    if(!idst.isEmpty()){

        List<Id> ids = new List<Id>();

    
    List<Account> accObj = [SELECT Id FROM Account WHERE Id =:idst AND recordTypeId =:devRecordTypeId];
    for(Account acc : accObj){
        ids.add(acc.Id);
    }
    System.debug('AccountData '+accObj);
    Database.executeBatch(new BatchPerformAccountActivityRollup(ids));
    }
}

}