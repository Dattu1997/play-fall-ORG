@isTest
public class EmailUtilityTest {
    
    @TestSetup
    static void testData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> uList = new List<User>{ 
            new User(Alias = 'standt', Email='anumanlakadidathu@gmail.com', 
                	EmailEncodingKey='UTF-8', UserName='standtTest@myorg.com',LastName='Test1', LanguageLocaleKey='en_US', 
                	LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/New_York'),
            new User(Alias = 'stTest', Email='test123@gmail.com', 
                	EmailEncodingKey='UTF-8', UserName='Usersalesforce@myorg.com',LastName='Test2', LanguageLocaleKey='en_US', 
                	LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/New_York'),
            new User(Alias = 'stTest', Email='Testing123@gmail.com', 
                	EmailEncodingKey='UTF-8', UserName='account@myorg.com',LastName='Test2', LanguageLocaleKey='en_US', 
                	LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/New_York'),
            new User(Alias = 'stTest', Email='testing123@gmail.com', 
                	EmailEncodingKey='UTF-8', UserName='EmailTest@myorg.com',LastName='Test2', LanguageLocaleKey='en_US', 
                	LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/New_York'),    
            new User(Alias = 'User', Email = 'testUser@iconiqcapital.com',
                    EmailEncodingKey='UTF-8', UserName='testAnalystUser@testacme.com',LastName='Test', LanguageLocaleKey='en_US',TimeZoneSidKey='America/New_York', 
                    LocaleSidKey='en_US', ProfileId = p.Id,PE_Activity_User__c = true,level__c ='Analyst')
        };
            System.debug('uList '+uList);
        insert uList;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RecordType2').getRecordTypeId();
        List<Account> acList = new List<Account>{
            new Account(Name = 'Test1_1', RecordTypeId = devRecordTypeId,Industry='Technology', Website = 'gmail.com'),
            new Account(Name = 'Test_2', RecordTypeId = devRecordTypeId,Industry='Technology', Website = 'yahooTest.com'),
            new Account(Name = 'Test1_3', RecordTypeId = devRecordTypeId,Industry='Technology', Website = 'bingTest.com'),
            new Account(Name = 'Test_4', RecordTypeId = devRecordTypeId,Industry='Technology', Website = 'Facebook.com'),
            new Account(Name = 'Test1_5', RecordTypeId = devRecordTypeId,Industry='Technology', Website = 'Google.com')
    
        };
            System.debug('acList '+acList);
        insert acList;
        List<Contact> conList = new List<Contact>{
            new Contact(lastName = 'Test',Email =uList[0].email,Employer_Company_2__c=acList[0].Id,Title ='CEO'),
        	new Contact(LastName = 'Test123',Email =uList[0].email,Employer_Company_2__c=acList[1].Id,Title ='CEO'),
            new Contact(LastName = 'Test1',Email =uList[0].email,Employer_Company_2__c=acList[2].Id,Title ='CEO'),
            new Contact(LastName = 'Test12',Email =uList[0].email,Employer_Company_2__c=acList[3].Id,Title ='CEO'),
            new Contact(LastName = 'Test1234',Email =uList[0].email,Employer_Company_2__c=acList[4].Id,Title ='CEO'),
            new Contact(LastName = 'Test1234',Email =uList[0].email,Employer_Company_2__c=acList[2].Id,Title ='CEO'),
            new Contact(LastName = 'Test1234',Email =uList[0].email,Employer_Company_2__c=acList[2].Id,Title ='CEO'),
    		new Contact(LastName = 'Test1234',Email =uList[0].email,Employer_Company_2__c=acList[2].Id,Title ='CEO')


        };
            System.debug('conList '+conList);
        insert conList;
            
        Contact_Tag__c contTag = new Contact_Tag__c(Contact_Name__c =conList[1].Id,value__c = 'Chief Executive Officer');
        insert contTag;
        Contact_Tag__c conTag = new Contact_Tag__c(Contact_Name__c =conList[1].Id,value__c = 'Chief Executive Officer');
        insert conTag;
        
    }
    @isTest
    static void findPeRelationshipByDomainTest(){
        List<String> domainList = new List<String>{'testuser1@gmail.com','testuser3@yahooTest.com','testuser2@bingTest.com'};        
        List<String> domainList1 = new List<String>{'testuser4@gmail.com'};
        Test.startTest();
        EmailUtility.findPeRelationshipByDomain(new PE_Activity__c(),domainList);
        EmailUtility.findPeRelationshipByDomain(new PE_Activity__c(),domainList1);
        Test.stopTest();        
    }
    @isTest
    static void getCeoContactTest(){
        System.debug('getCeoContactTest---------');
        List<Contact> conList = [SELECT Id, lastName,Title,Employer_Company_2__c FROM Contact WHERE LastName = 'Test'];
        List<COntact> con =[SELECT Id, lastName,Title,Employer_Company_2__c FROM Contact WHERE LastName = 'Test123'];
        Test.startTest();
        EmailUtility.getCeoContact(conList);
        EmailUtility.getCeoContact(con);
        Test.stopTest();
    }
    
    @isTest
    static void getMatchingContactTest(){
        System.debug('getMatchingContactTest =========');
        List<Contact> contactList = [SELECT Id, lastName,Title,Email,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test'];
        List<Contact> conObj = [SELECT Id, lastName,Title,Email,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test1'];
        List<Contact> contact = [SELECT Id, lastName,Title,Email,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test12'];
		List<Contact> conObjList = [SELECT Id, lastName,Title,Email,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test123'];
		List<Contact> con = [SELECT Id, lastName,Email,Title,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test1234'];
	    List<Contact> cont = [SELECT Id, lastName,Email,Title,Employer_Company_2__c,Employer_Company_2__r.Industry,Employer_Company_2__r.Website,Employer_Company_2__r.RecordTypeId FROM Contact WHERE LastName = 'Test1234'];

        Test.startTest();
        EmailUtility.getMatchingContact(new PE_Activity__c(),contactList);
        EmailUtility.getMatchingContact(new PE_Activity__c(),conObj);
        EmailUtility.getMatchingContact(new PE_Activity__c(),contact);
		EmailUtility.getMatchingContact(new PE_Activity__c(),conObjList);
	    EmailUtility.getMatchingContact(new PE_Activity__c(),con);
        EmailUtility.getMatchingContact(new PE_Activity__c(),cont);
		Test.stopTest();

    }
    @isTest
    static void sendExceptionEmailTest(){
        Test.startTest();
        EmailUtility.sendExceptionEmail(new PE_Activity__c(),'Outbound Email - no match');
        Test.stopTest();
    }
    

    @isTest
    static void sendInboundEmailTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();      
        
        email.subject = 'Test';
        email.htmlBody = 'This is htmlbBody';
        email.plainTextBody = 'This is just a test email for test class';
        email.toaddresses = new List<String>{'anumanlakadidathu@gmail.com'};
        email.ccAddresses = new List<String>{'testUser@iconiqcapital.com'};
        System.debug('ccAddresses '+email.ccAddresses);
        email.fromAddress = UserInfo.getUserEmail();
        email.plainTextBody = 'Testing the code from apex class  PE id: ';
		System.debug('email.plainTextBody '+email.plainTextBody);
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
		System.debug('email.binaryAttachments '+email.binaryAttachments);
        List<Messaging.InboundEmail.TextAttachment> textattachments = new List<Messaging.InboundEmail.TextAttachment>();
        Messaging.InboundEmail.TextAttachment textattachment = new Messaging.InboundEmail.TextAttachment();
        textattachment.body = 'csv';
        textattachment.fileName = 'data.csv';
        textattachment.mimeTypeSubType = 'text/plain';
        textattachments.add(textattachment);
        email.textAttachments = textattachments;
        MeetingNotesEmailService emailProcess = new MeetingNotesEmailService();
        Test.startTest();
        emailProcess.handleInboundEmail(email, env);
        EmailUtility.populateDescription('Meeting Notes',new PE_Activity__c(),email);
        Test.stopTest();
    }
     
}