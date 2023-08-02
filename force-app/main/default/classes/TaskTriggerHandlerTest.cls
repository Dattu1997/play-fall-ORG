@isTest
public class TaskTriggerHandlerTest {
    @TestSetup
    static void testSetuP(){
        //List<User> userList = new List<User>();
        Profile pf= [Select Id from profile where Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        User us = new User(firstname = 'ABC', 
                            lastName = 'XYZ', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US',
                            ProfileId = pf.Id);
        
        insert us;
        
        User u = new User(firstName = 'UserTest1',
                            lastName = 'XYZ1', 
                            email = uniqueName + '@test1' + orgId + '.org', 
                            Username = uniqueName + '@test1' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US',
                            ProfileId = pf.Id);
        
        insert u;
        Id RecordType1Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RecordType2').getRecordTypeId();

        Account acc = new Account( Name = 'testAccount',RecordTypeId = RecordType1Id,OwnerId = us.Id);
        insert acc;
        
        List<Task> taskList = new List<Task>();
        taskList.add(new Task(Subject = 'Call',whatId=acc.Id, OwnerId = u.Id,ActivityDate=Date.today()));
        insert taskList;
    }

    @isTest
    static void taskUpdate(){
        User user =[SELECT Id,firstName FROM User WHERE FirstName =: 'ABC'];
        System.runAs(user){
            
        
        Account a = [SELECT Id,Name,recordTypeId,SLAExpirationDate__c FROM Account WHERE Name =: 'testAccount'];
        System.debug('a'+a);
        List<Task> ts = [SELECT id,whatId,Subject,ActivityDate FROM Task WHERE whatId =: a.id ];
        ts[0].ActivityDate = Date.today().adddays(1);
        
        
        
        Test.startTest();
        
        Update ts;
        Test.stopTest();  
          List<Account> accList =[SELECT Id,Name,SLAExpirationDate__c FROM Account limit 1];
          System.debug('accList '+accList);  
          System.assertEquals(System.today().adddays(1), accList[0].SLAExpirationDate__c);
        }
    }
    

    @isTest
    static void taskDelete(){
        Account a = [SELECT Id,Name,recordTypeId FROM Account WHERE Name =: 'testAccount'];
        System.debug('a'+a);
        List<Task> ts = [SELECT id,whatId,Subject,ActivityDate FROM Task WHERE whatId =: a.id];
        
        Test.startTest();
        delete ts;
        Test.stopTest();
    }
    
}