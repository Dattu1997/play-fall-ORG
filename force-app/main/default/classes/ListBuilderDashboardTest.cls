@isTest
public with sharing class ListBuilderDashboardTest {
    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>{
            new Account(Name = 'Test_Account'),
            new Account(Name = 'Test_Account_2'),
            new Account(Name = 'Test_3'),
            new Account(Name = 'Test_Account_4')
        };
        insert accList;
    }
        @isTest
        static void createTest(){
            List< Map<string,string>> mapList = new List< Map<string,string>>();
            Map<string, string> accMap = new Map<string, string>();
            Account acc = [Select Id, Name FROM Account WHERE Name = 'Test_Account'];
            accMap.put('NAME', acc.Name);
            accMap.put('SF_ID', acc.Id);
            mapList.add(accMap);
            System.debug('mapList--'+mapList); 

            Test.startTest();
            ListBuilderDashboard.create(mapList);
            Test.stopTest();

        }
        @isTest
        static void initTest(){
            ListBuilderDashboard listBuilderTest = new ListBuilderDashboard();
            listBuilderTest.init();
        }
}