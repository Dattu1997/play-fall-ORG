global class AccountBatchApex implements Database.batchable<sObject> {

    

    global Database.QueryLocator Start(Database.BatchableContext bc ){
        String query = 'SELECT Id,AccountId, Name FROM Contact';

        return database.getQueryLocator(query);
    }

    global void Execute(Database.BatchableContext bc, list<Contact> scope){
        System.debug('Exectue'+scope);
        Map<Id, List<Contact>> conMap = new Map<Id, List<Contact>>();
        for(Contact con : scope ){
            if(!conMap.containsKey(con.AccountId)){
                conMap.put(con.AccountId, new List<Contact>());
            }
            conMap.get(con.AccountId).add(con);
        }
        System.debug('executed '+conMap);
        List<Account> lstCon = new List<Account>();
         for(Account a : [SELECT Id,Name,Number_Of_Contacts__c FROM Account WHERE Id =: conMap.keySet()]){

             a.Number_Of_Contacts__c = conMap.get(a.Id).size();
             lstCon.add(a);
           }
        
    Update lstCon;
}
    global void Finish(Database.BatchableContext bc){
        
    } 
}