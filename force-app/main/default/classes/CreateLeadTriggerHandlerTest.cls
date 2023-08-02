@isTest
public class CreateLeadTriggerHandlerTest {
    @isTest
    public static void checkAccount(){
    List<Account> account = new List<Account>();
    List<Lead> ld = new   List<Lead>();  
      Account acc = new Account();
      acc.Name = 'dattu';
      acc.Phone = '24525623';
      acc.Email__c = 'dattu@gamil.com';
        insert acc;
        Test.StartTest();
        
        Lead l = new Lead();
        l.LastName = 'dattu';
        l.Phone = '24525623';
        l.Company = 'Banking';
        l.Email = 'dattu@gamil.com';
        ld.add(l);
        insert ld;
        CreateLeadTriggerHandler.afterInsert(ld);
        Test.StopTest();
    } 
    @isTest
    public static void testLead(){
        List<Lead> lead = new List<Lead>();
            Account account = new Account();
             account.Name = 'Sai';
             account.Email__c ='Sai@gmail.com';
             account.Phone = '223244';
              Insert account;
        Test.StartTest();
        lead ld = new lead();
        ld.LastName = 'Vishal';
        ld.Phone = '87997655';
        ld.Company = 'Accounting';
        lead.add(ld);
        Insert lead;
        CreateLeadTriggerHandler.afterInsert(lead);
        
        Test.StopTest();
       System.assertEquals('Vishal',lead[0]. LastName);
        }
}