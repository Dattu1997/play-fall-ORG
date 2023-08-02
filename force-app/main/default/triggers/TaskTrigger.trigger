trigger TaskTrigger on Task (before insert, before delete, before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            TaskTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isDelete){
            System.debug('before delete ');
            TaskTriggerHandler.beforeDelete(Trigger.old);
        }
        if(Trigger.isUpdate){
            System.debug('In Before Update Trigger');
            TaskTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){

    }

}