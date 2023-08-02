public with sharing class LookUpLwcController {
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name,Description From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        System.debug('sQuery '+sQuery);
        for (sObject obj: database.query(sQuery)) {
            System.debug('obj '+obj);
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name,Description From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        System.debug('sQuery '+sQuery);
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    @AuraEnabled
    public static String getAccountContactUpadate(String acc, String con){
        System.debug('con1 '+con);
        String toastMessage = '';
        try{
            acc = acc.removeStart('"');
            acc = acc.removeEnd('"');
            System.debug('acc '+acc);
            con = con.removeStart('"');
            con = con.removeEnd('"');
            System.debug('con2 '+con);
            List<Contact> conList =[SELECT Id From Contact WHERE AccountId =: acc And Id =: con];
            if(conList.size()>0){
                toastMessage = 'info';
            }
            else {
                Contact conObj =[SELECT Id, LastName,AccountId From Contact WHERE Id =: con];
                    System.debug(conObj + '----------');
                    conObj.AccountId = acc;
                    update conObj;
                    toastMessage = 'success';
            }
        }
        catch(exception e){
            toastMessage = 'error';
        }
        return toastMessage;
    }
    @AuraEnabled(cacheable = true)
    public static List<Contact> retriveAccountsData(string accountId){
        List<Contact> conList =[SELECT Id, FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE AccountId =:accountId];
        System.debug('conList----- '+conList);
        return conList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        
        return [SELECT Id, Name FROM Account];
    }
    @AuraEnabled(cacheable=true)
    public static string deleteContacts(List<Account> acc, List<Contact> con) {
        System.debug('acc-- '+acc);
        System.debug('con-- '+ con);
        try {
            Set<Id> conIds = new Set<Id>();
            for(Contact conObj : con){
                conIds.add('In contact--'+conObj.Id);
                
            }
            System.debug(conIds);
            List<Contact> conList =[SELECT Id From Contact WHERE AccountId =: acc AND Id =: con];
            System.debug('conList In delete==='+ conList);
            if(conList.size()>0){
                update conList;
            }
            
            
            return 'Success: Contact(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
    }
}