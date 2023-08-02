public with sharing class accountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> fetchAccounts() {

        return [ SELECT Id, Name, Industry, ( SELECT Id, FirstName, LastName,Email,Phone FROM Contacts ) FROM Account LIMIT 10 ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        
        return [SELECT Id, Name, Description, Industry FROM Account LIMIT 10];
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountRecord(String recordId){
        //System.debug('accId To update account--'+recordId);
        // try {
        //     if(String.isNotBlank(recordId)){
        //         Account acc =[SELECT Id, Name FROM Account WHERE Id =: recordId];
        //         update acc;
        //     }
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
        return [SELECT Id,Name, Description, Industry FROM Account Where Id =:recordId];
        
    }
    @AuraEnabled
    public static List<Account> getAccountUpdate(Id accId){
        System.debug('accId To update account--'+accId);
        try {
            if(String.isNotBlank(accId)){
                Account acc =[SELECT Id, Name FROM Account WHERE Id =: accId];
                update acc;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return [SELECT Id, Name FROM Account WHERE Id =: accId];
    }
}