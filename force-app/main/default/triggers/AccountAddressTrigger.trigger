trigger AccountAddressTrigger on Account (before insert, before update) {
    System.debug('In Account Trigger');
    if(trigger.isInsert){
        System.debug('in insert');
        AccountAddressTriggerHandler.beforeInsert(Trigger.New);
    }
    if(trigger.isUpdate){
        AccountAddressTriggerHandler.beforeUpdate(Trigger.New);
    }

}