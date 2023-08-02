@isTest
public class ContactBatchApexTest {
    @isTest
    static void batchAccount(){
    Contact con = new Contact();
    con.LastName = 'test';
    con.FirstName = 'test1';    
    con.Email = 'fytyu@gmail.com';
    con.Birthdate = Date.today().addDays(7);
    insert con;
    
    Test.startTest();
        
    Database.executeBatch(new ContactBatchApex());
    Test.stopTest();
    }
    
}