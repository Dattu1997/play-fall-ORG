public with sharing class SoslController {
    

    public static void createContact(String accName) {
        List<List<Account>> accSoslList = [FIND :accName IN ALL FIELDS RETURNING Account(Id,Name)];
        System.debug('accSoslList '+accSoslList);
        List<Account> allAccList = new List<Account>();
        for(List<Account> acList : accSoslList){
            allAccList.addAll(acList);
        }
        System.debug('allAccList-- '+ allAccList);
        
    }
}