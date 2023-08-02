@isTest
public class ContactTriggerHandlerTest {
    @TestSetup
    static void contactData(){
        Account acc = new Account();
        acc.Name = 'test1';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        
        
    }
    
    @isTest
    static void createContact(){
        Contact con2 = [SELECT Id,LastName FROM Contact WHERE LastName = 'test'];
        Test.startTest();
        delete con2;
        Test.stopTest(); 
    }

}