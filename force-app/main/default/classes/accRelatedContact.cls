public with sharing class accRelatedContact {
    @auraEnabled(cacheable=true)
        public static List<Contact> getContacts(String accountId)
        {
            List<Contact> conList=[SELECT Id,LastName,AccountId FROM Contact WHERE AccountId=:accountId LIMIT 10000];
            return conList;
        }
}