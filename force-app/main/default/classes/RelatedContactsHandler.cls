public with sharing class RelatedContactsHandler {

    public static void deleteAccount(List<Account> account){
        List<Id> accountId = new  List<Id>();
        System.debug('List Account' + account);
        
        
        for(Account acc : account){
            accountId.add(acc.id);
            
        }
        List<Affiliation__c> affList = [SELECT Id, Employment_Relationship__c, Employment_Status__c FROM Affiliation__c WHERE Account__c in : accountId];
        if(affList.size()>0){
            delete affList;
        }
        System.debug('For New Account'+affList);
        
        System.debug('deleted Affiliation'+ affList);
     }
    
}