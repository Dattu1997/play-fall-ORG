@RestResource(urlMapping='/accountData/*')
global with sharing class AccountDataUsingWorkbench {

    @HttpPost
    global Static Id fetchAccount(String FirstName, String LastName, String Email,String Phone){
        
        
        Contact obj = new Contact();
        obj.firstName = FirstName;
        obj.lastName = LastName;
        obj.Email = Email;
        obj.Phone = Phone;
        System.debug('obj '+obj);
        insert obj;
        return Obj.Id;
    }
    
    
}