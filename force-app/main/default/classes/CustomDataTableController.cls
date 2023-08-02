public with sharing class CustomDataTableController {
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts(){
        return [SELECT Id, Name,Description,Type, Ownership, Industry, Website FROM Account limit 10];
    }
    @AuraEnabled(cacheable=true)
     public static List<wrapperAccount> getFieldSet(String objectName, String fieldSetName){
        Schema.SObjectType objectType = null;
        if(String.isNotBlank(objectName) && String.isNotEmpty(objectName)){
        objectType = Schema.getGlobalDescribe().get(objectName);
        }
        List<wrapperAccount> wrapperAccountList = new List<wrapperAccount>();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        wrapperAccount wrap = new wrapperAccount();
        for(Schema.FieldSetMember fieldSetMem : fieldSet.getFields()){
            System.debug('fieldSetMem: '+ fieldSetMem);
            System.debug('fieldName: '+ fieldSetMem.getLabel());
            wrapperAccountList.add(new wrapperAccount(fieldSetMem.getLabel(), String.valueOf(fieldSetMem.getSObjectField())));
        }   
        System.debug('wrapperAccountList' +wrapperAccountList);  
        return wrapperAccountList;
    }
    
    public class wrapperAccount{
        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public String fieldlabel;

        @AuraEnabled
        public String fieldValue;

        public wrapperAccount(){

        }
        public wrapperAccount(String fieldlabel, String fieldName){
            this.fieldlabel = fieldlabel;
            this.fieldName = fieldName;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> getDynamicQuery(String objectName, String fieldSetName){
        List<wrapperAccount> wrapperAccountList = new List<wrapperAccount>();
        System.debug('wrapperAccountList in getDynamic--'+wrapperAccountList);
        if(String.isNotBlank(objectName) && String.isNotBlank(fieldSetName)){
            wrapperAccountList = getFieldSet(objectName,fieldSetName);
        }
        String query = 'SELECT ';
        for(wrapperAccount wrap : wrapperAccountList){
            System.debug('wrap: '+ wrap);
            query+= wrap.fieldName + ',';
        }
        // if(String.isNotBlank(whereClause) && String.isNotEmpty(whereClause)){

        // }
        System.debug('query '+query);
        query += ' Id FROM '+ objectName;
        System.debug('query123-- '+query);
        List<SObject> records = Database.query(query);
        System.debug('records: '+ records);
        return records;
    }

}