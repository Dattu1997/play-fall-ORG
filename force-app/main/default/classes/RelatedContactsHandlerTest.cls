@isTest
public with sharing class RelatedContactsHandlerTest {
    @isTest
    public static void accTest(){
        List<Account> account = new List<Account>();
        List<Affiliation__c> affList = new List<Affiliation__c>();
        Account acc = new Account();
        acc.name='abc';
        acc.Industry='It';
        account.add(acc);
        insert account;

        Affiliation__c aff = new Affiliation__c();
        aff.Account__c = acc.Id;
        affList.add(aff);
        insert affList;
        Test.startTest();
        
        delete account;
        Test.stopTest();
        List<Account> a =[SELECT Id,Name,Industry FROM Account];
        System.assertEquals(0,a.size());
        List<Affiliation__c> Affiliation = [SELECT Id,Account__c FROM Affiliation__c];
        System.assertEquals(0,Affiliation.size());
    }

}