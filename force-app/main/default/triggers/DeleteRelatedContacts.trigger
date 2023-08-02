trigger DeleteRelatedContacts on Account (before delete) {

    if(trigger.isBefore && trigger.isDelete){
    
            RelatedContactsHandler.deleteAccount(trigger.old);
        

    }

}