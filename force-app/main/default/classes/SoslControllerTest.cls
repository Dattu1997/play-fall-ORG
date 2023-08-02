@isTest
public class SoslControllerTest {
   
//    static @IsTest
//     void makeData(){
//         Account acc = new Account();
//         acc.Name = 'testing';
//         insert acc;

//         Id [] fixedSearchResults= new Id[1];
//         fixedSearchResults[0] = acc.Id;
//         Test.setFixedSearchResults(fixedSearchResults);
//         SoslController.createContact('testing');
       
//     }
    @IsTest
    static void testSoslController(){
        Account acc = new Account();
            acc.Name = 'testing';
            insert acc;

        Test.startTest();
        List<Id> fixedSearchResults= new List<Id>();
        fixedSearchResults.add(acc.Id);
        System.debug(fixedSearchResults);
        Test.setFixedSearchResults(fixedSearchResults);
        SoslController.createContact('testing');
        Test.stopTest();
    }
    
}