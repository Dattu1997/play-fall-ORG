@IsTest 
public class AccountRestApiTest {
    @testSetup
    static void dataSetup() {
        Account acc = new Account(Name = 'Testing',Phone = '8673297602');
        Account accs = new Account(Name = 'Anu',Phone = '32446');
        insert acc;
        insert accs;
        Contact con = new Contact();
        con.LastName ='dattu';
        con.Title = 'AccountManager';
        con.AccountId = acc.Id;
        insert con;
    }
static testMethod void testPostMethod()
    {
        
        
        String data = '{"records" :[{ "attributes" : {"type" : "Account", "referenceId" : "ref1"}, "name" : "SampleAccount1", "phone" : "1111111111","website" : "www.salesforce1.com", "numberOfEmployees" : "100","industry" : "Banking"}]}';
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        
        request.requestUri ='/services/apexrest/newAccountData';
        request.httpMethod ='POST';
        RestContext.request = request;
        RestContext.response = res;
        request.requestBody = Blob.valueOf(data);
        AccountRestApi.Post();
        res =RestContext.response;
       String actual = res.responseBody.toString();
       Test.stopTest();
    }
    static testMethod void testPostMethodFail()
    {
        
        
        String data = '{"records" :[{ "attributes" : {"type" : "Account", "referenceId" : "ref1"},  "phone" : "1111111111","website" : "www.salesforce1.com", "numberOfEmployees" : "100","industry" : "Banking"}]}';
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        
        request.requestUri ='/services/apexrest/newAccountData';
        request.httpMethod ='POST';
        RestContext.request = request;
        RestContext.response = res;
        request.requestBody = Blob.valueOf(data);
        AccountRestApi.Post();
        res =RestContext.response;
        
        String actual = res.responseBody.toString();
   
        Test.stopTest();
        
    }
    @isTest
    public static void getTestContact(){
        Test.startTest();
        List<Account> acc = [Select Id,Name,Phone from Account LIMIT 1];
        List<Contact> con = [select Id,LastName,Phone,Title from Contact where AccountId = :acc[0].Id];
        RestRequest request = new RestRequest();
        RestResponse res = RestContext.response;
        request.requestURI = '/services/apexrest/newAccountData';  //Request URL
        request.httpMethod = 'GET';//HTTP Request Type
        request.addParameter('AccountId',acc[0].Id);
        RestContext.request = request;
        RestContext.response= res;
        AccountRestApi.getContact();
        
        
        Test.stopTest();
       // Account acc = getContact.doGet();
       System.assertEquals('dattu',con[0].LastName);
        }
    @isTest
    public static void getTestContactFail(){
        Test.startTest();
        List<Account> acc = [Select Id,Name,Phone from Account where Name = 'Anu'];
        List<Contact> con = [select Id,LastName,Phone,Title from Contact where AccountId = :acc[0].Id];
        RestRequest request = new RestRequest();
        RestResponse res = RestContext.response;
        request.requestURI = '/services/apexrest/newAccountData';  //Request URL
        request.httpMethod = 'GET';//HTTP Request Type
        request.addParameter('AccountId',acc[0].Id);
        RestContext.request = request;
        RestContext.response= res;
        AccountRestApi.getContact();
        
        
        Test.stopTest();
       // Account acc = getContact.doGet();
       System.assertEquals('dattu',con[0].LastName);
        }
    
}