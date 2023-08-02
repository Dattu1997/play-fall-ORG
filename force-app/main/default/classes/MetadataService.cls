public class MetadataService {

    @AuraEnabled
    public static void handleUpsert(String fullName, String label, String fieldWithValues) {
        System.debug('fullName-'+fullName);
        System.debug('label'+label);
        System.debug('MetadataService--'+fieldWithValues);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(fieldWithValues);
        System.debug('results--- in metadata-'+results);
        Map<String, Object> fieldWithValuesMap=new Map<String, Object>();
        for (Object obj: results) {
            fieldWithValuesMap.putAll((Map<String, Object>)obj);
        }
        
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();        
        customMetadata.fullName = fullName+'.'+label;        
        customMetadata.label = label;        
        for (String key: fieldWithValuesMap.keySet()) {            
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();            
            customField.field = key;            
            customField.value = fieldWithValuesMap.get(key);            
            customMetadata.values.add(customField);            
        }
        System.debug('customData--'+customMetadata);
       	Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();        
        mdContainer.addMetadata(customMetadata);        
        MetadataServiceCallback callback = new MetadataServiceCallback();   
        Id jobId = Test.isRunningTest() ? 'a0cM00000043ST4' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        system.debug('jobId:'+jobId);
    }
}