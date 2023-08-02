public with sharing class WrapperClass {
    @AuraEnabled(cacheable = true)
    public  static wrapper WrapperAccount() {
      Account accObj = [SELECT Id, Name, Phone, Industry 
    
                     FROM Account LIMIT 1];
      //return  acc;              
     Opportunity opp = [SELECT Id, Name, CloseDate, StageName, Description
                        FROM Opportunity
                        LIMIT 1];
     Lead ld = [SELECT Id, Name, Company, Email, Title
                FROM Lead
                LIMIT 1];   
                
    wrapper wrp = new wrapper();
    wrp.acc1 = accObj;
    System.debug('wrp.acc1'+ wrp.acc1);
    wrp.opp1 = opp;
    wrp.ld1 = ld;
    return wrp;
    
    }
    

    public class wrapper {
        @AuraEnabled
         public Account acc1;

         @AuraEnabled
         public Opportunity opp1;

         @AuraEnabled
         public Lead ld1;
    }
}