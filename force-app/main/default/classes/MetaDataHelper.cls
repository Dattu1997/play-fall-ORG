public class MetaDataHelper {
    @AuraEnabled(cacheable = true)
    public static wrapper getMetadataRecord(string metadataName, String label) {
        wrapper wrap = new wrapper();
        System.debug('in metadatahelper----'+metadataName);
        System.debug('label--'+label);
        String query = null;
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(metadataName);
        System.debug('objType--'+objType);
        Map<String, Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
        wrap.fields = new List<String>(fields.keySet());
        System.debug('fields--'+fields.keySet()); 
        query = 'Select '+ fields.keySet().toString().removeStart('{').removeEnd('}') +' FROM '+metadataName;
        System.debug('query1--'+query);
        wrap.records = Database.query(query);
        return wrap;
    
    }

    public class wrapper{

        @AuraEnabled
        public List<String> fields = new List<String>();

        @AuraEnabled
        public List<SObject> records = new List<SObject>();
    }

}