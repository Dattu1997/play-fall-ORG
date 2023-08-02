public class SelectedTagsController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getSelectedTags(String recordId){
        //System.debug('Accounts '+accountId);
        List<Contact> conList=[SELECT FirstName,LastName,Phone,Email FROM Contact WHERE AccountId =: recordId];
        System.debug('Contact '+conList);
        return conList;
    }
}