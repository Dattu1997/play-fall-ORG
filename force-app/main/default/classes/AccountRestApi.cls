/*
@author        A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
* @modifiedBy     A dattu       <anumanlakadidathu@rplayful-wolf-cz3uwx-dev-ed.my.salesforce.com>
* @maintainedBy   A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
* @version        52.0
* @created        2022-01-16
* @modified       2022-01-20
* @systemLayer    Apex Class
*/
//@descrpition  The Account related contact will get inserted through postman.

@RestResource(urlMapping='/newAccountData/*')
global class AccountRestApi 
{
    @HttpPost
    global static Void Post() 
    {
        List<SObject> accList = new List<SObject>();
        RestRequest req = RestContext.request;
        System.debug('req '+req);
        RestResponse res = RestContext.response;
        System.debug('res '+res);
        WrapperForAccount wra  = (WrapperForAccount)JSON.deserialize(req.requestbody.toString(), WrapperForAccount.class);
        System.debug('wra '+wra);
        Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestbody.toString());
        SObject newSobject;
        
        System.debug('the response'+wra.records.size());
        
        
        for(Integer i = 0; i<wra.records.size(); i++){
            Schema.SObjectType  typeField = Schema.getGlobalDescribe().get(wra.records[i].attributes.type);
            System.debug('the ---->'+wra.records[i].attributes.type);
            newSobject = typeField.newSobject();
            newSobject.put('Industry', wra.records[i].industry);
            newSobject.put('Name', wra.records[i].name);
            newSobject.put('Phone',wra.records[i].phone);
            newSobject.put('Website', wra.records[i].website);
            
            accList.add(newSobject);
            
        }
        System.debug('list of accWarp '+accList);
        
        Map<String,Object> accountResponse;
        
        try
        {
            insert accList;
            accountResponse = response(200,'Sucess',true,accList,'');
            
        }
        catch(exception e)
        {
            accountResponse = response(400,'Error',false,new List<Account>(), e.getMessage());
        }
        System.debug('response data '+accountResponse);
        res.addHeader('Content-Type','application/json');
        res.responseBody= Blob.valueOf(JSON.serialize(accountResponse));
    }
    global static Map<String,Object> response(Integer statusCode, String msg, Boolean isSucess, List<Account> accList, String errorMessage){
        
        Map<String,Object> accMap = new Map<String,Object>();
        if(isSucess && !accList.isEmpty()){
            accMap.put('statuscode',statusCode);
            accMap.put('Message',msg);
            accMap.put('status',isSucess);
            accMap.put(' records',accList);
            
        }
        
        else{
            accMap.put('Statuscode',statusCode);
            accMap.put('Message',msg);
            accMap.put('status',isSucess);
            accMap.put('no records',errorMessage);
        }
        
        return accMap;
        
    }
    @HttpGet
    global static List<Contact> getContact()
    {
        RestRequest request = RestContext.request;
        String accId = request.params.get('AccountId');
        system.debug(accId);
      //  List<Contact> updatecons = new List<Contact>();
        List<Contact> cons;
        if(accId!=''){
            cons = [SELECT Id,LastName,Title,Phone FROM Contact WHERE AccountId = :accId];
        }
            
            
            if(!cons.isEmpty()){
                for(Integer i =0;i<cons.size();i++)
                {
                    cons[i].Lastname = 'demo '+i;
                }
                return cons;
            }
            
            else{
                return null;
            }
        }
        
    }