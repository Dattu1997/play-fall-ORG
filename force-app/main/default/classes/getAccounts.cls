public with sharing class getAccounts {
    
        @auraEnabled(cacheable=true)
        public static List<Contact> getDataFromContact(){
                List<Contact> conList = [Select Id, FirstName, LastName, Email, Phone From Contact limit 10];
                try{
                   return conList;
                }
                
                catch(Exception e){
                   throw new AuraHandledException(e.getMessage());
                }
              }
        }