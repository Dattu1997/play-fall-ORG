/**
 * @File Name          : customDataLoaderController.cls
 * @Description        : 
 * @Author             : Anup Kage
 * @Group              : 
 * @Last Modified By   : Anup Kage
 * @Last Modified On   : 16/6/2020, 9:33:54 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/6/2020   Anup Kage     Initial Version
**/
public with sharing class customDataLoaderController {
    
    
    @AuraEnabled(cacheable = true) //
    public static wrappFieldWithType getMappingFields(String csvObjectLabel){
     
        System.debug('csvObjectLabel----> '+csvObjectLabel);
        Boolean includeData = false;
        Boolean isApplicationExists = false;
        Map<String, CSV_File_Upload_Field__mdt>  columnNameByfield = new Map<String, CSV_File_Upload_Field__mdt>();
        Map<String,Schema.DisplayType>  columnTypeByfield = new Map<String,Schema.DisplayType>();
        List<Application__mdt> recordObject = [SELECT Id, Object_API_Name__c, Object_Label__c
                                                    FROM Application__mdt 
                                                    WHERE Label =: csvObjectLabel ];
        
        System.debug('recordObject----> '+recordObject);
        if(recordObject.size() > 0 || !recordObject.isEmpty()){
            List<CSV_File_Upload_Object__mdt> csvFileUploadObj = [SELECT Id, Object_API_Name__c, Parent_Record_Id__c
                                                                    FROM CSV_File_Upload_Object__mdt 
                                                                    WHERE Application__r.id =: recordObject[0].id];
            System.debug('csvFileUploadObj---> '+csvFileUploadObj);

            List<Content_File_Upload__mdt> dropZoneContectFileUpload = [SELECT Id, Document_Description__c, Document_Type__c, Content_URL_Field_API_Name__c,Content_Version_Field_API_Name__c
                                                                                    FROM Content_File_Upload__mdt 
                                                                                    WHERE Application__r.id =: recordObject[0].id];
            System.debug('csvFileUploadObj---> '+dropZoneContectFileUpload);

            Settings__c dropZoneSettings =  Settings__c.getInstance();
            includeData = dropZoneSettings.Include_Data__c;

            Boolean showBothFileOpption = false;
            Boolean showContentFileOpption = false;
            Boolean showDataFileOpption = false;

            if(!csvFileUploadObj.isEmpty() && !dropZoneContectFileUpload.isEmpty()){ //Populating  For both file Type 
                showBothFileOpption = true;
            }
            else if(csvFileUploadObj.isEmpty() && !dropZoneContectFileUpload.isEmpty()){  //Populating  For Content File Type
                showContentFileOpption = true;
            }
            else if(!csvFileUploadObj.isEmpty() && dropZoneContectFileUpload.isEmpty()){
                showDataFileOpption = true;
            }
            else{
                return null;
            }
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(recordObject[0].Object_API_Name__c).getDescribe().fields.getMap();
            if(!csvFileUploadObj.isEmpty()){

                for(CSV_File_Upload_Field__mdt field : [SELECT CSV_Column_Name__c, sequence__c, Field_API_Name__c, Required__c
                                                            FROM CSV_File_Upload_Field__mdt
                                                            WHERE CSV_File_Upload_Object__r.id =:  csvFileUploadObj[0].id
                                                            Order By sequence__c asc NULLS LAST,CSV_Column_Name__c asc ])
                {
                    if(recordObject[0].Object_API_Name__c != null && field.Field_API_Name__c != null && fieldMap.containsKey(field.Field_API_Name__c)){
                        Schema.DisplayType fieldType = fieldMap.get(field.Field_API_Name__c).getDescribe().getType(); 
                        columnTypeByfield.put(field.CSV_Column_Name__c.toLowerCase(),fieldType);
                        System.debug('columnTypeByfield---> '+columnTypeByfield);
                        columnNameByfield.put(field.CSV_Column_Name__c.toLowerCase(), field);
                        System.debug('columnNameByfield---> '+columnNameByfield); 
                    }else{
                        System.debug('Please Enter correct FieldApi Name OR Please contact with salesforce Admin');
                    }          
                }
            }
            return new wrappFieldWithType(columnNameByfield, JSON.serialize(columnTypeByfield), showBothFileOpption, showContentFileOpption, showDataFileOpption,  includeData, true);
        }else{
            return new wrappFieldWithType(false);
        }
    }

    public class wrappFieldWithType{
        @AuraEnabled
        public Map<String, CSV_File_Upload_Field__mdt> mapOfColumnName;
        @AuraEnabled
        public String mapOfColumnType;
        @AuraEnabled
        public Boolean showBothFileOpption;
        @AuraEnabled
        public Boolean showContentFileOpption;
        @AuraEnabled
        public Boolean showDataFileOpption;
        // @AuraEnabled
        // public List<String> documentTypeLst;
        @AuraEnabled
        public Boolean includeData;
        @AuraEnabled
        public Boolean isApplicationExists = false;

        public wrappFieldWithType(Map<String, CSV_File_Upload_Field__mdt> mapOfColumnName, String mapOfColumnType, Boolean showBothFileOpption, Boolean showContentFileOpption, Boolean showDataFileOpption, Boolean includeData, Boolean isApplicationExists){
            this.mapOfColumnName = mapOfColumnName;
            this.mapOfColumnType = mapOfColumnType;
            this.showBothFileOpption = showBothFileOpption;
            this.showContentFileOpption = showContentFileOpption;
            this.showDataFileOpption = showDataFileOpption;
            this.includeData = includeData;
            this.isApplicationExists = isApplicationExists;
        }

        public wrappFieldWithType(Boolean isApplicationExists){
            this.isApplicationExists = isApplicationExists;
        }
    }

    @AuraEnabled(cacheable = true) //
    public static CSV_File_Upload_Object__mdt getCSVFileUploadObject(String csvObjectLabel){
        Application__mdt recordObject = [SELECT Id, Object_API_Name__c, Object_Label__c
                                                    FROM Application__mdt 
                                                    WHERE  Label =: csvObjectLabel  ];

       List<CSV_File_Upload_Object__mdt> csvFileUpload = [SELECT Id, Object_API_Name__c, Parent_Record_Id__c
                                                    FROM CSV_File_Upload_Object__mdt 
                                                WHERE Application__r.id =: recordObject.id Limit 1];
                                                
        if(!csvFileUpload.isEmpty()){
            return csvFileUpload[0];
        }
        return null;
    }
    public class wrappResult{
        @AuraEnabled
        public List<Map<String, Object>> successRecordList;
        @AuraEnabled
        public List<Map<String, Object>> errorRecordList;
        public wrappResult(List<Map<String, Object>> successRecordList, List<Map<String, Object>> errorRecordList){
            this.successRecordList = successRecordList;
            this.errorRecordList = errorRecordList;
        }
    }
    @AuraEnabled
    public static wrappResult insertRecords(String recordList, String objectApiName){
        System.debug('recordList>>>'+recordList);
        System.debug('objectApiName=='+objectApiName);
        List<Object> recFieldSet = (List<Object>)JSON.deserializeUntyped(recordList);
        System.debug('recFieldSet--'+recFieldSet);
        String userLocale = getUserDateFormat();  //for en_IN --> d/M/yyyy h:mm a
        System.debug('userLocale-----'+ userLocale);
        // for(Object obj : recFieldSet){
        //     Map<String,Object> a = (Map<String,Object>)obj;
        //     Object dt = a.get('birthdate');
        //     System.debug('date------' + dt);
        // }
        // for(Object fld : recFieldSet){    
        //     Map<String,Object> data = (Map<String,Object>)fld;
        //     Object birthdate = data.get('birthdate');
        //     system.debug('birthdate------'+ birthdate);
        //     String strDate = birthdate.toString();
        //     system.debug('strDate-----'+ strDate);
        //     Date dt = Date.parse(strDate);  
        //     Datetime d = Date.newInstance(dt.year(), dt.month(),dt.day());
        //     system.debug('Parsed Date is' + d.format(userLocale));   
        // }
        Type listType = Type.forName('List<' + objectApiName + '>');
        System.debug('listType=='+listType);
        List<SObject> records = (List<SObject>)JSON.deserialize(recordList, listType);
        System.debug('records--------------- '+records);
        
        List<Database.UpsertResult> resultList = Database.upsert(records, false);
        System.debug('resultList--------------- '+resultList);
        // Iterate through each returned result
        List<Map<String, Object>> successRecordList = new List<Map<String, Object>>();
        List<Map<String, Object>> errorRecordList = new List<Map<String, Object>>();
        Integer count = 0 ;
        for (Database.UpsertResult sr : resultList) {
            if (sr.isSuccess()) {
                Map<String, Object> rec = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(records[count]));
                // rec.put('Status','Success');
                rec.put('Id',sr.getId());
                successRecordList.add(rec);
                // Operation was successful, so get the ID of the record that was processed
                // System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    Map<String, Object> rec = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(records[count]));
                    // rec.put('Status','Error');
                    String errorMessage = err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields();
                    rec.put('ErrorMessage',errorMessage);
                    errorRecordList.add(rec);

                    // System.debug('The following error has occurred.');                    
                    // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    // System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
            count ++;
        }
        System.debug('count--------------- '+count);
        // System.debug('errorRecordList'+errorRecordList.size());
        return new wrappResult(successRecordList, errorRecordList);
    }
    @AuraEnabled
    public static String fetchAllRecords(String csvObjectLabel,String filterType, String filterCondition, String recordId){
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('id');
        String objectApiName;
        String lookupFieldApiName;
        Map<String, String> fieldApiByColumnName = new Map<String, String>();
        fieldApiByColumnName.put('id', 'id');

        Application__mdt recordObject = [SELECT Id, Object_API_Name__c, Object_Label__c
                                                    FROM Application__mdt 
                                                    WHERE Label =: csvObjectLabel ];

        System.debug('recordObject----> '+recordObject);
        CSV_File_Upload_Object__mdt csvFileUploadObj = [SELECT Id, Object_API_Name__c, Parent_Record_Id__c
                FROM CSV_File_Upload_Object__mdt 
                WHERE Application__r.id =: recordObject.id ];
        System.debug('csvFileUploadObj---> '+csvFileUploadObj);

        for(CSV_File_Upload_Field__mdt field : [SELECT CSV_Column_Name__c,sequence__c, Field_API_Name__c, Required__c, CSV_File_Upload_Object__r.Object_API_Name__c, CSV_File_Upload_Object__r.Parent_Record_Id__c
                                                FROM CSV_File_Upload_Field__mdt
                                                WHERE CSV_File_Upload_Object__r.id =: csvFileUploadObj.id 
                                                Order By sequence__c asc NULLS LAST,CSV_Column_Name__c asc])
        {
            fieldSet.add(field.Field_API_Name__c.toLowerCase());
            System.debug('fieldSet---> '+fieldSet);
            fieldApiByColumnName.put(field.Field_API_Name__c.toLowerCase(), field.CSV_Column_Name__c.toLowerCase());
            if(objectApiName == null){
                objectApiName = field.CSV_File_Upload_Object__r.Object_API_Name__c;
            }
            if(lookupFieldApiName == null){
                lookupFieldApiName = field.CSV_File_Upload_Object__r.Parent_Record_Id__c;
            }            
        }
        List<String> fieldList = new List<string>(fieldSet);
        String queryString = 'SELECT '+String.join(fieldList, ',') +' FROM '+objectApiName;
        String whereCondition = '';
        if(filterType == 'All Data'){
            queryString += ' LIMIT 10000 ';
        }else if(filterType == 'Related Data' && String.isNotBlank(lookupFieldApiName)){
            whereCondition += lookupFieldApiName +' =: recordId';
        }else if(filterType == 'Filtered Data' && String.isNotBlank(lookupFieldApiName) && String.isNotBlank(filterCondition)){
            whereCondition += lookupFieldApiName +' =: recordId AND ' + filterCondition; //String.escapeSingleQuotes(filterCondition);
        }
        if(String.isNotBlank(whereCondition)){
            queryString += ' WHERE ' +whereCondition;
        }
        // Prepare csv file string
        String columnDivider = ',';
        String lineDivider = '\n';
        String responseCsv ='';
        for(String fldApiName : fieldList){
            responseCsv += fieldApiByColumnName.get(fldApiName) + columnDivider;
        }
        responseCsv += lineDivider;
        System.debug('test>>>>>>>>>>>>'+queryString);
        List<SObject> recordList = Database.query(queryString);
        for(SObject record : recordList){
            for(String fldApiName : fieldList){
                responseCsv += record.get(fldApiName) + columnDivider;
            }
            responseCsv += lineDivider;
        }
        return responseCsv;
    }
   
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    @AuraEnabled
    public static Void uploadFile(List<Map<String, Object>> files, String recordId, String csvObjectLabel, String contentDocumentType){

        System.debug('contentDocumentType---> '+contentDocumentType);
        System.debug('csvApplicationLabel---> '+csvObjectLabel);
        System.debug('files---> '+files);
        Type listType = Type.forName('List<Map<String,String>>');
        System.debug('----listType----- '+listType);
        List<Map<String,String>> records = (List<Map<String,String>>)JSON.deserialize(contentDocumentType, listType);
        System.debug('records---> '+records);
        Map<String, String> mapDocuType = new Map<String, String>();
        for(Map<String, String> doctypeFiles :records ){
            System.debug('doctypeFiles---> '+doctypeFiles);
            System.debug('doctypeFiles---> '+doctypeFiles.get('fileName'));
            System.debug('doctypeFiles---> '+doctypeFiles.get('type'));
            String documentType = doctypeFiles.get('type');
        
            mapDocuType.put(doctypeFiles.get('fileName'), doctypeFiles.get('type'));
        }

        Map<String, ContentVersion> relatedDocuments = new Map<String, ContentVersion>();
        Map<String, ContentVersion> documentTypes = new Map<String, ContentVersion>();
        
        List<ContentVersion> relatedDocumentsValues = new List<ContentVersion>();
        Set<Id> cvIdLst = new  Set<Id>();
        List<ContentDocumentLink> lstOfcontentDocument= new List<ContentDocumentLink>();
        for (Map<String, Object> file :files) {
            System.debug('Inside for loop'+file);
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            System.debug('relatedDocument====> '+relatedDocument);
            System.debug('relatedDocumentTitle====> '+relatedDocument.Title);
           // avoid duplicate
           if(relatedDocuments.size()<1){
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            contentVersionFile.Document_Type__c = mapDocuType.get(relatedDocument.Title);
            //contentDocumentType.add(contentVersionFile.Document_Type__c);
            contentVersionFile.Application_Name__c = csvObjectLabel;
            relatedDocuments.put(relatedDocument.Title, contentVersionFile);
            documentTypes.put(mapDocuType.get(relatedDocument.Title), contentVersionFile);
           }else if(!relatedDocuments.containsKey(relatedDocument.Title)){
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            contentVersionFile.Document_Type__c = mapDocuType.get(relatedDocument.Title);
            //contentDocumentType.add(contentVersionFile.Document_Type__c);
            contentVersionFile.Application_Name__c = csvObjectLabel;
            relatedDocuments.put(relatedDocument.Title, contentVersionFile);
            documentTypes.put(mapDocuType.get(relatedDocument.Title), contentVersionFile);
            }
        }
        System.debug('mapDocuType>>>>>>>> '+ mapDocuType.values());
        //System.debug('documentTypesMap>>>>>'+ documentTypes.keySet());
        System.debug('relatedDocuments===> '+relatedDocuments);
        System.debug('relatedDocuments key size===> '+relatedDocuments.keySet().size());
        System.debug('relatedDocuments values size===> '+relatedDocuments.values().size());
        relatedDocumentsValues = relatedDocuments.values();
        Integer relatedDocumentsSize = relatedDocuments.size();
        System.debug('relatedDocuments===> '+relatedDocumentsSize);
        Database.saveResult[] srFiles = Database.insert(relatedDocumentsValues);

        //Insert content documentlink 
        Set<Id> contentVersionIdSet = new  Set<Id>();
        for(ContentVersion cv : relatedDocumentsValues ){
            contentVersionIdSet.add(cv.id);
        }
        List<ContentVersion> testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id In :contentVersionIdSet];
        System.debug('testContent---> '+testContent);
        List<ContentDocumentLink> insertContentDocumentLink = new  List<ContentDocumentLink>();
        for(ContentVersion cv : testContent){
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = recordId;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId=cv.ContentDocumentId;
            insertContentDocumentLink.add(contentlink);
        }
        if(!insertContentDocumentLink.isEmpty()){
            System.debug('insertContentDocumentLink>>>>>>>'+ insertContentDocumentLink);
            INSERT insertContentDocumentLink;
        }

       List<Content_File_Upload__mdt> dropZoneContectFileUpload = [SELECT Id, Document_Status_Field_API_Name__c, Document_Type__c, 
                                                                                     Content_URL_Field_API_Name__c,Content_Version_Field_API_Name__c
                                                                            FROM Content_File_Upload__mdt 
                                                                            WHERE Document_Type__c IN: documentTypes.keySet() ];

                                                                            


        System.debug('dropZoneContectFileUpload---> '+ dropZoneContectFileUpload[0].Document_Type__c);
        //System.debug('dropZoneContectFileUpload.type---> '+ contentDocumentType);
        System.debug('dropZoneContectFileUpload.size---> '+ dropZoneContectFileUpload.size());
        Id recordId1 = (Id)recordId; 
        String objectName = String.valueOf(recordId1.getsobjecttype());
        System.debug('objectName--> '+objectName);
        String query = 'SELECT ID, Contract_Document_Vers_Id_Field_API_Name__c, NDA_Document_Status_Field_API_Name__c,'+ 
                        'NDA_Document_URL_Field_API_Name__c,NDA_Document_Vers_Id_Field_API_Name__c  '+
                        ' FROM '+ objectName +' WHERE ID=\''+recordId +'\'';
        //String query = 'SELECT ID, Contract_Document_Vers_Id_Field_API_Name__c, NDA_Document_Status_Field_API_Name__c, NDA_Document_URL_Field_API_Name__c FROM '+ objectName +' WHERE ID=\''+recordId +'\'';

        
        Map<Id, SObject> idsToUpdate = new Map<Id, SObject>(DataBase.query(query));
        
        System.debug('idsToUpdate>>>>'+ idsToUpdate.keySet());
       
        List<SObject> sObjectsToUpdate = new List<SObject>();
        
        SObject sobj;

        for (Id idToUpdate : idsToUpdate.keySet()) {
            sobj = idToUpdate.getSObjectType().newSObject(idToUpdate);
            System.debug('sobj==== '+sobj);
            // Set the Name field dynamically
            for(Integer i=0; i < dropZoneContectFileUpload.size(); i++){
              //  if(dropZoneContectFileUpload[0].Document_Type__c == 'NDA Document' || dropZoneContectFileUpload[0].Document_Type__c == 'Contract Document' ){
                    if( dropZoneContectFileUpload[i].Document_Status_Field_API_Name__c != null){
                        sobj.put( dropZoneContectFileUpload[i].Document_Status_Field_API_Name__c, System.now());
                    }
                    System.debug('ContentUrl==== '+documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c));
                    
                    if(dropZoneContectFileUpload[i].Content_Version_Field_API_Name__c != null && documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c).id != null){
                         sobj.put(dropZoneContectFileUpload[i].Content_Version_Field_API_Name__c, documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c).id);
                    }
                    System.debug('ContentUrl==== '+documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c).ContentUrl);
                    if(dropZoneContectFileUpload[i].Content_URL_Field_API_Name__c != null && documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c).ContentUrl != null){
                        sobj.put(dropZoneContectFileUpload[i].Content_URL_Field_API_Name__c, documentTypes.get(dropZoneContectFileUpload[i].Document_Type__c).ContentUrl);
                    }
               // }
            }
    }
        System.debug('sobj==== '+sobj);
        UPDATE sobj;
    }

    //Retriving Document Type
    @AuraEnabled(cacheable = true) 
    public static List<String> getDocumentTypeList(String csvObjectLabel){
        System.debug('csvObjectLabel---> '+csvObjectLabel);
        Application__mdt recordObject = [SELECT Id, Object_API_Name__c, Object_Label__c
                                                    FROM Application__mdt 
                                                    WHERE Label =: csvObjectLabel ];

        System.debug('recordObject----> '+recordObject);
        List<String> documentTypeList = new List<String>();
        for(Content_File_Upload__mdt cfUploadObject : [SELECT Id, Document_Type__c
                                                                  FROM Content_File_Upload__mdt 
                                                                  WHERE Application__r.id =: recordObject.id ])
        {
            documentTypeList.add(cfUploadObject.Document_Type__c);
        }


        System.debug('documentTypeList---> '+ documentTypeList);
        return documentTypeList;
    }
    /*
    * DROP-017
    */
    private static Map<String,String> localeToDateTimeFmtMap;

    public static String getUserDateFormat() {
        String userLocale = UserInfo.getLocale();
        getLocaleToDateTimeFmtMap();
        if(!localeToDateTimeFmtMap.containsKey(userLocale))    
            return 'yyyy-mm-dd';
            
        return localeToDateTimeFmtMap.get(userLocale).substringBefore(' ');
    }
    
    public static String getUserDateTimeFormat() { //getUserDateTimeFormat: e.g. M/d/yyyy hh.mm.ss
        String userLocale = UserInfo.getLocale();
        getLocaleToDateTimeFmtMap();
        if(!localeToDateTimeFmtMap.containsKey(userLocale))
            return 'yyyy-mm-dd hh.mm.ss';
        return localeToDateTimeFmtMap.get(userLocale);
    }
    
    public static Map<String,String> getLocaleToDateTimeFmtMap () { //Returns a map of user locale
        if(localeToDateTimeFmtMap == null)
            localeToDateTimeFmtMap = new Map<String,String> {
                'en_IN'        =>   'd/M/yyyy h:mm a',
                'en_US'         =>  'M/d/yyyy h:mm a'
                
            };
            return localeToDateTimeFmtMap;
    }

    @AuraEnabled
    public static String getRelatedObject(String recordId){
        System.debug('record--'+recordId);
        
        Id currentRecordId = Id.valueOf(recordId);
        //Storing the Object in variable and returning.
        String ObjectName = currentRecordId.getSObjectType().getDescribe().getName();
        System.debug('record--'+ObjectName);

        return ObjectName;
    }

}