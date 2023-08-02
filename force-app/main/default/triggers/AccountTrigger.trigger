trigger AccountTrigger on Account (before delete,before update) {
    if(Trigger.isDelete){
        System.debug('In Account Trigger'+ 'isDelete');
        AccountTriggerHandler.beforeDelete(Trigger.old);
        //AccountTriggerHandler.beforeDeleteContact(Trigger.new,Trigger.old);
    }
    if(Trigger.isUpdate){
        System.debug('In Account Trigger'+ 'isUpdate');
        AccountTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
    }

}