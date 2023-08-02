public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    @AuraEnabled
    public  static void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);
        } else {
            System.debug(' fail : '+ result);
        }
    }
    @AuraEnabled
    public static String createUpdateMetadata(String fullName, List<String> label, List<Object> fieldVal){
        System.debug('ss==='+fieldVal);
        System.debug('fullName--'+fullName);
        System.debug('label'+label);
        
        Map<Object, Object> mapVal = new Map<Object, Object>();
        for(Object s : fieldVal){
            Map<Object, Object> mapVal1 = (Map<Object, Object>)s;
            mapVal.putAll(mapVal1);
            System.debug('mapVal=='+mapVal);
        }
        System.debug('fieldWithValuesMap--'+mapVal);
        if(fullName == null || label == null || (mapVal == null)){
            System.debug('Values are missing');
            return null;
        }else{
            List<String> newList = new List<String>();
             for(String str : label){
                newList.add(str);
            }
            System.debug('newList=='+newList);
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                customMetadata.fullName = fullName;
                customMetadata.label = string.join(newList, ',');  
            
            System.debug('customMetadata==='+customMetadata);
            for(Object key : mapVal.keySet()){
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = string.valueOf(key);
                customField.value = (mapVal.get(key) == true || mapVal.get(key) == false) ? mapVal.get(key) : string.valueOf(mapVal.get(key)); 
                customMetadata.values.add(customField);
            }
            System.debug('customMetadata--12--'+customMetadata);
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            CreateUpdateMetadataUtils callback = new CreateUpdateMetadataUtils();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            System.debug('jobId--'+jobId);
            return jobId != null ? 'success':'fail';
        }
    
    }

    @AuraEnabled
    public static wrapperList getObjFields(String objectName){
        System.debug('objectName: '+objectName);
        Map<String, String> mapStr = new Map<String, String>();
        wrapperList wrap = new wrapperList();
        if(String.isNotBlank(objectName)){
            List<string> apiNames = new List<string>();
            List<string> apiNames1 = new List<string>();
            List<string> lookUpField = new List<string>();
            String fields;
            SObjectType ObjectType = Schema.getGlobalDescribe().get(objectName);
            Map<String,Schema.SObjectField> metadataFields = ObjectType.getDescribe().fields.getMap();
            for(String strList : metadataFields.keySet()){
                Schema.DescribeFieldResult a_Field_Description = metadataFields.get(strList).getDescribe();
                System.debug('a_Field_Description==='+strList);
                apiNames.add(a_Field_Description.getLabel());
                apiNames1.add(a_Field_Description.getLabel().toLowerCase());
                mapStr.put(a_Field_Description.getLabel(), strList);
                mapStr.put(a_Field_Description.getLabel().toLowerCase(), strList);
                    if(a_Field_Description.getType() == Schema.DisplayType.Reference){
                        System.debug('strList in if--'+a_Field_Description.getReferenceTo());
                        fields = String.valueOf(a_Field_Description.getReferenceTo());
                        lookUpField.add(fields);
                    }
                
           }

           apiNames.addAll(apiNames1);
           wrap.fieldlabel = apiNames;
           wrap.fieldAPIName = mapStr;
           wrap.fieldLookUp = lookUpField;
          System.debug('maplistlabelName==='+wrap.fieldlabel);
          System.debug('apiName'+wrap.fieldLookUp);

            return wrap;
        }else {
            return null;
        }
    }

    public class wrapperList{
        @AuraEnabled
        public List<String> fieldlabel;

        @AuraEnabled
        public Map<String, String> fieldAPIName;

        @AuraEnabled
        public List<String> fieldLookUp;

        public wrapperList(){

        }
        public wrapperList(List<String> fieldlabel, Map<String, String> fieldAPIName, List<String> fieldLookUp){
            this.fieldlabel = fieldlabel;
            this.fieldAPIName = fieldAPIName;
            this.fieldLookUp = fieldLookUp;
        }
    }

    @AuraEnabled
    public static Map<String,list<string>> getObjFieldsMetadata(List<String> objectName){
        System.debug('objectName: '+objectName);
        Map<String,list<string>> metadataFields = new Map<String,list<string>>();
        //if(String.isNotBlank(objectName)){
            for(String str : objectName){
                SObjectType ObjectType = Schema.getGlobalDescribe().get(str);
                Map<String,Schema.SObjectField> metadataFields1 = ObjectType.getDescribe().fields.getMap();
                metadataFields.put(str,new List<string>(metadataFields1.keySet()));
            }
            System.debug('metadataFields==='+metadataFields);
            return metadataFields;
        //}
        
    }
    
    @AuraEnabled
    public static String getAppLabel(String label){
        System.debug('label---'+label);
        Application__mdt recordObject = [SELECT Id, Object_API_Name__c, Object_Label__c
                                                    FROM Application__mdt 
                                                    WHERE  Label =: label];
          System.debug('label---'+recordObject);               
        return recordObject != null ? 'success':'fail' ;
    }
}