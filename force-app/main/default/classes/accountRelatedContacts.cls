@RestResource(urlMapping='/Accounts/*/contacts')
    global with sharing class accountRelatedContacts {
        @HttpGet
        global static List<Account> getAccount(){
            RestRequest request = RestContext.request;
            //String contactRequestURI = request.requestURI;
            //String accountId = String.valueOf(contactRequestURI.substring(contactRequestURI.lastIndexOf('/') +1));
            String accountId = request.requestURI;
            List<Account> accList = [SELECT Id, Name, (SELECT Id,Name FROM Contacts) FROM Account WHERE Id =:accountId];
            system.debug('Result is :' +accList);
            Return accList;
        }
    }