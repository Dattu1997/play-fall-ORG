public with sharing class LwcLoadingController {
    @AuraEnabled
    public static List<Account> getAccountData() {
        return [SELECT Id, Name, Type, Phone, CreatedDate FROM Account LIMIT 50000];
    }
}