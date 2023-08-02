public class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountContacts(String recordId){
        //System.debug('Accounts '+accountId);
        List<Contact> conList=[SELECT FirstName,LastName,Phone,Email FROM Contact WHERE AccountId =: recordId];
        System.debug('Contact '+conList);
        return conList;
    }
    @AuraEnabled
    public static Boolean getContactsSaved(List<Contact> con){
        System.debug('Con '+con);
        //List<Contact> contLict =[SELECT FirstName,LastName,Phone,Email FROM Contact WHERE Id =: con];
        //System.debug('contLict '+contLict);
        try {
            
            update con;
            return true;
        } catch(Exception e) {
            return false;
        }    }

}