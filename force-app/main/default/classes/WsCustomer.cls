@RestResource(urlMapping='/insertaccount')
global with sharing class WsCustomer {
   
   @HttpPost
    global static Account doPost(){
        String accountJSON = RestContext.request.requestBody.toString();
        JsonAccount serializedAcc = (JsonAccount)(JSON.deserialize(accountJSON, JsonAccount.class));
    
        Account acc = [SELECT Id,Name,Phone,Industry,Website FROM Account WHERE id =: serializedAcc.Id];
        acc.Name = serializedAcc.name;
        acc.Phone = serializedAcc.phone;
        acc.Industry = serializedAcc.Industry;
        acc.Website = serializedAcc.Website;
        upsert acc;
        return acc;
        
    }

    global class JsonAccount{
        public String id      {get;set;}
        public String name    {get;set;}
        public String phone   {get;set;}
        public String industry {get;set;}
        public String website {get;set;}
    }
}