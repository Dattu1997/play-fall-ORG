public with sharing class imageWithAccount {
    @AuraEnabled(cacheable = true)
    public static Account imageAccount() {
         

        Account acc = [SELECT Id, Name, Phone, Industry, Website, Fax  
                       FROM Account 
                       LIMIT 1];
                       System.debug('acc'+acc);
         return acc;
         

    }
}