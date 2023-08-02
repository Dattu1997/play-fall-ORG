public with sharing class displayTagDataController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        
        return [SELECT Id, Name, Description, Industry,Website FROM Account LIMIT 1000];
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountRecord(String recordId){
        return [SELECT Id,Name, Description, Industry FROM Account Where Id =:recordId];
        
    }
    
    @AuraEnabled
    public static List<Contact> retrieveContacts(Id accId){
        List<Contact> conList = new List<Contact>();
        try {
            if(String.isNotBlank(accId))
                conList = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId =: accId LIMIT 5000];
        } catch (Exception e) {
            System.debug('retrieveContacts Exception: '+ e.getMessage());
        }
        return conList;
    }

    @AuraEnabled
    public static List<Contact> deleteMultipleContactRecord(List<Contact> conObj, Id accId){
        System.debug('conObj-- '+conObj);
        System.debug('accId--'+accId);
        List<Id> contIds = new   List<Id>();
        for(Contact c : conObj){
            contIds.add(c.Id);
        }
        if(!contIds.isEmpty()){
            List<Contact> contList = [SELECT Id, AccountId FROM Contact WHERE Id IN: contIds AND AccountId =: accId];
            for(Contact c : contList){
                c.AccountId = null;
            }
            update contList;
        }
        
        return [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId =: accId];
    }
    @AuraEnabled
    public static List<Contact> getContactUpdate(Id contId, Id accntId){
        System.debug('contId '+contId);
        System.debug('accountId '+accntId);
        try {
            if(String.isNotBlank(contId)){
                Contact c = [SELECT Id, AccountId FROM Contact WHERE Id =: contId];
                c.AccountId = accntId;
                update c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId =: accntId];
    }
}