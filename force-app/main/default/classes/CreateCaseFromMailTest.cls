@isTest
public with sharing class CreateCaseFromMailTest {
 @isTest   
    public static void CreateCaseFromMailTest() {
        List<String> toadress = new List<String>();
         toadress.add('testTo@mail.com');
        Messaging.inboundEmail testMail = new Messaging.InboundEmail();
        Messaging.InboundEnvelope testMailEvnlop = new Messaging.InboundEnvelope();
        testMail.subject ='testSubject';
        testMail.fromName = 'testFromName';
        testMail.plainTextBody = 'testPlainTextBody';
        testMail.fromAddress = 'test@mail.com';
        testMail.toAddresses = toadress;
        Account a = new Account(Name = 'Testacc');
        insert a;
        Contact c = new Contact(LastName = 'Testname', Email = 'test@mail.com',AccountId = a.Id);
        insert c;
        Test.startTest();
        CreateCaseFromMail.handleInboundEmail(testMail,testMailEvnlop);
        Test.stopTest();


    }
}