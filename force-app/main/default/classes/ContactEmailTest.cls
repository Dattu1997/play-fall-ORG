@isTest
public  class ContactEmailTest {
    
    @TestSetup static void createData(){
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.Birthdate = Date.today().addDays(7);
        con.Email = 'test@gmail.com';
        
        insert con;
        
    }
    @isTest static void emailContactTest(){
    test.startTest();
    ContactEmail.emailContact();
    test.stopTest(); 

    }
}