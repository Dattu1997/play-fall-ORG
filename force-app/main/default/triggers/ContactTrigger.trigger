trigger ContactTrigger on Contact (before insert, before delete) {

    if(Trigger.isBefore && Trigger.isInsert){
        ContactTriggerHandler.beforeInsert(Trigger.new);
    }
     if(Trigger.isBefore && Trigger.isDelete){
        ContactTriggerHandler.beforeDelete(Trigger.old);
     }

}