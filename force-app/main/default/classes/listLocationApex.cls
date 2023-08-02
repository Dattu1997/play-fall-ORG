public with sharing class listLocationApex {
    @AuraEnabled(cacheable=true)
    public static list<Listing__c> getListinglocation(string searchKey) {
        string searchKeyword = '%' + searchKey + '%';
		
       // create  listing record to store search result 
        list<Listing__c> ListRecord = new list<Listing__c>();
     
	   // query listing records
        for(Listing__c lisObj : [SELECT Id,Name,Category__c,State__c,Price__c
                                 FROM Listing__c
                                 WHERE State2__c LIKE : searchKeyword]){
                                ListRecord.add(lisObj);
        }
        
        
        if(ListRecord.size() ==0){
            
            throw new AuraHandledException('No Record Found..');
            
        }
        System.debug('the size'); 
         return ListRecord;
    }
}