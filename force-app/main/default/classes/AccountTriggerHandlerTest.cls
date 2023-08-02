@isTest
public class AccountTriggerHandlerTest {
    @TestSetup
    static void testSetup(){
        Id RecordType1Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RecordType1').getRecordTypeId();
        Account acc = new Account( Name = 'testAccount',OwnerId = Userinfo.getUserId(),RecordTypeId = RecordType1Id,AccountOwner__c='Test owner');
        insert acc;
        
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(LastName = 'test' , AccountId = acc.Id));        
    }
    
    @isTest
    static void accountUpdateOwner(){
        Account a = [SELECT Id,Name,AccountOwner__c,OwnerId FROM Account WHERE Name = 'testAccount'];
        User us = [SELECT id,name FROM user WHERE name = 'Sfdc Salesforce'];
        
        Test.startTest();
        a.OwnerId = us.Id;
        update a;
        
        Test.stopTest();  
        if(Trigger.isExecuting){
            System.assertEquals(null, a.AccountOwner__c);
        }
        
    } 
    
    @isTest
    static void deleteAccountTest(){
        Account a = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'testAccount'];
        Test.startTest();
        delete a;
        Test.stopTest();  
    } 
    
    
}