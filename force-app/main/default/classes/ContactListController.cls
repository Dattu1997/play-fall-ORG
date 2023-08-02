public with sharing class ContactListController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accId){
        return [SELECT Id, Name, Email FROM Contact WHERE AccountId =: accId];
    }
}