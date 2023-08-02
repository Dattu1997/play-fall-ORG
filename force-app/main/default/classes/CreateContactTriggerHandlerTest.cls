@isTest
public with sharing class CreateContactTriggerHandlerTest {
    @isTest
    public static void conTest(){
        List<Contact> conData = new List<Contact>();
        Account a = new Account(Name='Test');
        Insert a;
        Account acc = [select id from Account Limit 1];
        conData.add(new Contact(LastName='DattuTest1',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
        conData.add(new Contact(LastName='DattuTest1',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
        conData.add(new Contact(LastName='DattuTest2',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
		conData.add(new Contact(LastName='DattuTest3',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
		conData.add(new Contact(LastName='DattuTest4',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
		conData.add(new Contact(LastName='DattuTest5',FirstName='A',RecordTypeId = '0125j0000005b2JAAQ',AccountId = acc.Id));
        Test.startTest();
        Insert conData;
        
        Account account = new Account(Name='Dattu');
        Insert account;
        Account ac = [select id from Account where Name = 'Dattu' Limit 1 ];
        Contact con =[SELECT id,LastName,FirstName,RecordTypeId,AccountId From Contact LIMIT 1];
        con.AccountId = ac.Id;
        System.debug(ac.Id);
       System.debug('After update'+ con);
        Update con;
        Test.stopTest();
    }
}