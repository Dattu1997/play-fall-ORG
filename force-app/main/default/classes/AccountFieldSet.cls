public with sharing class AccountFieldSet {

    public List<Schema.FieldSetMember> getFields(){
        return SObjectType.Account.FieldSets.Account_Field_Set.getFields();
    }
    @AuraEnabled(cacheable=true)
    public Account getAccountFieldSet() {
        System.debug('in Account---FieldSet---');
        List<wrapperAccount> wrapperList = new List<wrapperAccount>();
        String querySelect = 'SELECT Id';
        for(Schema.FieldSetMember f : this.getFields()) {
            querySelect += f.getFieldPath() + ', ';
        }
        querySelect += ' FROM Account LIMIT 5';
        System.debug('In Account FieldSet------' +querySelect);
        return Database.query(querySelect);
    }
    public class wrapperAccount{
        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public String fieldlabel;

        @AuraEnabled
        public String fieldType;
        
        public wrapperAccount(String fieldName ,String fieldlabel, String fieldType){
            this.fieldName = fieldName;
            this.fieldlabel = fieldlabel;
            this.fieldType = fieldType;
        }
    }

}