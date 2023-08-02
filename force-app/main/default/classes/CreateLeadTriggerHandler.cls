/*
@author        A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @modifiedBy     A dattu       <anumanlakadidathu@rplayful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @maintainedBy   A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @version        52.0
 * @created        2022-01-18
 * @modified      
 * @systemLayer    Apex Handler Class
 */
 //@description  when lead is created the acccount and contact should create.
 //@description In account the email and phone is matching it should merge if not it should create new account and contact. 
  
 public with sharing class CreateLeadTriggerHandler {
     // afterInsert is method it insert lead, account and contact and to merge the account.
    //If account is  matching with lead, email and phone it will merge in account. 

        public static void afterInsert(List<Lead> ldList){
            //Boolean b = true;
            List <Account> acc = new List<Account>();
             Set<String> email = new Set<String>();
             Set<String> phone = new Set<String>();
        Map<String, Lead> mapObj = new Map<String, Lead>();
        Map<String, Account> mapAcc = new Map<String, Account>(); 
              for(Lead l : ldList){
                       phone.add(l.Phone);
                       email.add(l.Email);
                       mapObj.put(l.Phone+';'+l.Email,l);
                       
                       
                    }
         for(Account acct: [Select id, Name, Phone, Email__c from Account Where Phone IN : phone AND Email__c IN : email]){
                             acct.Name =mapObj.get(acct.Phone+';'+acct.Email__c).LastName;
                             acc.add(acct);
                     System.debug('The new Account'+acc);
                             mapAcc.put(acct.Phone+';'+acct.Email__c,acct);
                     System.debug('The new Map Account'+mapAcc);
         }
                         if(!acc.isEmpty()){
                            Update acc;
                             System.debug('The new Account Updated'+acc);
                          }
                         // if(b){
        //If account is not matching with lead email and phone new account and contact will create. 
        
                List<Account> acList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                for(Lead l :ldList){
                    System.debug('The lead'+ l);
                    if(!mapAcc.containsKey(l.Phone+''+l.Email)){
                        System.debug('The lead'+ l.Phone);
                        System.debug('The lead'+ l.Email);
                       Account a = new Account();
                       a.Name = l.LastName;
                       a.Email__c = l.Email;
                       a.Phone = l.Phone;
                       acList.add(a);
                    }
                 }
                              System.debug('the account'+acList);
                  Insert acList;
                  for(Account accs : [Select Id,Name,Email__c,Phone from Account where id in :acList ]){
                
        
                    Contact con = new Contact();
                    con.LastName = accs.Name;
                    con.AccountId = accs.Id;
                    con.Phone = accs.Phone;
                    con.Email = accs.Email__c;
                    conList.add(con);
                  }
                              System.debug('The contact details'+conList);
                   INSERT conList;
                
            }
               
       // }
}