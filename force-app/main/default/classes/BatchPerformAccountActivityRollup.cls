public class BatchPerformAccountActivityRollup implements Database.batchable<sObject>{
        List<Id> idList = new List<Id>();
       

    public BatchPerformAccountActivityRollup(List<Id> idList){
        this.idList = idList;


    }
    public Database.QueryLocator Start(Database.BatchableContext bc ){
        string query  = 'SELECT Id, Name, Phone, Industry,SLAExpirationDate__c, OwnerId FROM Account WHERE Id IN :idList';
        System.debug('StartMethod '+query);
        return database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('Scope '+scope);
        Set<String> setValues = new Set<String>{'Email','Call','Send letter'};
        Map<Id, Account> accMap = new Map<Id, Account>();
        accMap.putAll(scope);
        System.debug('accMap '+accMap);
        
        List<Task> ts = [SELECT Id, Subject, AccountId, OwnerId, ActivityDate  FROM Task WHERE AccountId =:accMap.keySet() AND Subject IN: setValues];
        System.debug('ts '+ts);
        if(!ts.isEmpty()){
            System.debug('ts '+ts);
            for(Task tsObj : ts){

                Account acc = accMap.get(tsObj.AccountId); //Getting Account's related to Task WhatId.
                    System.debug('Acc===='+acc);
                    if(tsObj.AccountId == acc.Id){ // checking if Task owner is equal to related Account Owner.
                        System.debug('Owner check');
                        System.debug('tsObj.Subject '+tsObj.Subject);
                        System.debug('tsObj.ActivityDate'+tsObj.ActivityDate);
                        System.debug('acc.SLAExpirationDate__c: '+ acc.SLAExpirationDate__c);
                        if(tsObj.Subject == 'Call' && (acc.SLAExpirationDate__c != null || tsObj.ActivityDate > acc.SLAExpirationDate__c)){
                           // System.debug('The If Condition '+acc.SLAExpirationDate__c);
                            acc.SLAExpirationDate__c = tsObj.ActivityDate;
                            System.debug('The If Condition '+acc.SLAExpirationDate__c);
                            
                        }
                        if(tsObj.Subject == 'Email' && (acc.SLAExpirationDate__c != null || tsObj.ActivityDate > acc.SLAExpirationDate__c)){
                            acc.SLAExpirationDate__c = tsObj.ActivityDate;
                        }
                        if(tsObj.Subject == 'Send letter' && (acc.SLAExpirationDate__c != null || tsObj.ActivityDate > acc.SLAExpirationDate__c)){
                            acc.SLAExpirationDate__c = tsObj.ActivityDate;
                            System.debug('The If Condition '+acc.SLAExpirationDate__c);
                        }
                    }
                accMap.put(acc.Id, acc);
            } 
        }
        System.debug('accMap '+ accMap.values());
        update accMap.values();
    }
    public void finish(Database.BatchableContext BC){
            
                
   }

}