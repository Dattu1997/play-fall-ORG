/**
 *  @Class Name : ListBuilderController 
 *  @Description : Controller for listBuilder.lwc
 *  @Modification Log   
 *  IG-1294 - Replaced FieldWrapper wrapper class with FieldWrapper Apex class
*/

public with sharing class ListBuilderController {

    /**
     * @description : Creates a new Relationship_Tag_Item for every checked Relationship and selected Relationship_Tag.
     * @return : List Account (List of Relationships that are assigned to inserted Relationship_Tag_Item__c)
     * @param  List_String (List of selected Relationship Ids)
     * @param  Id  (Id of selected Relationship_Tag__c record)
    */
    @AuraEnabled
    public static List<Account> createRelationTagItem(List<String> selectedRelationshipIds, Id tagId){
        
        List<Relationship_Tag_Item__c> relTagItemList = new List<Relationship_Tag_Item__c>();
        Map<Id, Relationship_Tag_Item__c> relTagItemMap = new Map<Id, Relationship_Tag_Item__c>();

        Map<Id, Account> relMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN: selectedRelationshipIds]);
        
        for(Relationship_Tag_Item__c relTagItem : [SELECT Id, Relationship_Company__c FROM Relationship_Tag_Item__c WHERE Relationship_Tag__c =: tagId]){
            relTagItemMap.put(relTagItem.Relationship_Company__c , relTagItem);
        }

        if(!relMap.isEmpty()){
            Relationship_Tag__c tag = [SELECT Id, Sharing_Type__c FROM Relationship_Tag__c WHERE Id =: tagId];
            for(Account rela : relMap.values()){
              
                if(!relTagItemMap.containsKey(rela.Id)){
                    Relationship_Tag_Item__c relTagItem = new Relationship_Tag_Item__c();
                    relTagItem.Relationship_Tag__c = tag.Id;
                    relTagItem.Relationship_Company__c = rela.Id;
                    relTagItem.Parent_Tag_Sharing_Type__c = tag.Sharing_Type__c;
                    relTagItemList.add(relTagItem);   
                }
            }
        }

        try {
            if(!relTagItemList.isEmpty())
                insert relTagItemList;
        } catch (DMLException ex) {
           //SobjectUtility.insertExceptionMessage('ListBuilderController', 'createRelationTagItem', ex.getMessage());
        }
        return relMap.values();
    }

    /**
     * @description : To get every Relationship related to selected Relationship_Tag to load ListBuilder Manage mode table.
     * @return : List SObject (Relationship records related to selected Relationship_Tag)
     * @param  Id (Id of selected Relationship_Tag__c record)
     * @param String (label of List_Builder_Object__mdt record)
     * @info : https://app.clickup.com/t/8406164/IG-1046
    */
    @AuraEnabled
    public static List<SObject> getTagRelatedRelationships(Id tagId, String label){
        if(String.isNotBlank(tagId)){
            Map<Id, Account> relToRelTagMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN (SELECT Relationship_Company__c FROM Relationship_Tag_Item__c WHERE Relationship_tag__c =: tagId)]);
            return getDynamicQuery(label, '', new List<Id>(relToRelTagMap.keySet()));
        }
        else
            return null;
    }

    /**
     * @description : To fetch Relationships related to Relationship_Tag by Name value
     * @return : UtilityWrapper (returns Id of Relationship_Tag and List of Relationships related to Relationshp_Tag)
     * @param String (Name of Relationship_Tag)
     * @param String (label of List_Builder_Object__mdt record)
     * @info : https://app.clickup.com/t/8406164/IG-1182
    */
    @AuraEnabled
    public static UtilityWrapper getRelationsByTagName(String tagName, String label){
        UtilityWrapper utilWrap = new UtilityWrapper();
        List<SObject> records = new List<SObject>();
        List<Id> relationshipIds = new List<Id>();
        if(String.isNotBlank(tagName)){
            tagName = tagName.contains('\\') ? tagName.remove('\\') : tagName;
            List<Relationship_Tag__c> tags = [SELECT Id, Name FROM Relationship_Tag__c WHERE Name =: tagName];
            if(!tags.isEmpty()){
                utilWrap.recordId = tags[0].Id;
                Map<Id, Account> relToRelTagMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN (SELECT Relationship_Company__c FROM Relationship_Tag_Item__c WHERE Relationship_tag__c IN: tags)]);
                if(!relToRelTagMap.isEmpty())
                    utilWrap.records = getDynamicQuery(label, '', new List<Id>(relToRelTagMap.keySet()));
            }
        }else{
            
        }
        return utilWrap;
    }

    /**
     * @description :   Queries Relationship_Tag_Item__c record based on selected Relationships and selected Tag
     *                  Unassigns selected Relationships from fetched Relationship_Tag_Item__c record and updates record
     *                  {Only for Managed mode}
     * @return List SObject (Relationship records of updated Relationship_Tag_Item__c record)
     * @param  List_Id (List of Relationship Id's )
     * @param Id  (Id of selected Relationship_Tag__c record)
     * @param String (label of List_Builder_Object__mdt record)
    */
    @AuraEnabled
    public static List<SObject> unassignRelationship(List<Id> relList, Id tagId, String label){
        Map<Id, Account> relToRelTagMap = new Map<Id, Account>();
        try {
            List<Relationship_Tag_Item__c> relTagItemList = [SELECT Id, Relationship_Company__c, Relationship_Tag__c FROM Relationship_Tag_Item__c WHERE Relationship_Company__c IN: relList AND Relationship_Tag__c =: tagId];
            for(Relationship_Tag_Item__c relTagItem : relTagItemList){
                relTagItem.Relationship_Company__c = null;
            }
            update relTagItemList;
            relToRelTagMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN (SELECT Relationship_Company__c FROM Relationship_Tag_Item__c WHERE Relationship_tag__c =: tagId )]);
        } catch (Exception e) {
            //SobjectUtility.insertExceptionMessage('ListBuilderController', 'unassignRelationship', e.getMessage());
        }
        return getDynamicQuery(label, '', new List<Id>(relToRelTagMap.keySet()));
    }

    /**
     * @description : Creates a new Relationship_Tag_Item for every selected Relationship from search lookup and selected Relationship_Tag.
     * @return : List SObject (Relationship record from search lookup to add to data table)
     * @param Id (Selected Relationship Id from lookup search in ListBuilder Managed mode)
     * @param Id (Id of selected Relationship_Tag__c record)
     * @param String (label of List_Builder_Object__mdt record)
    */
    @AuraEnabled
    public static List<SObject> createRelTagItem(Id relaIds, Id tagId, String label){
        Relationship_Tag__c tag = [SELECT Id, Sharing_Type__c FROM Relationship_Tag__c WHERE Id =: tagId];
        try {
            Relationship_Tag_Item__c newTagItem = new Relationship_Tag_Item__c(
                                                      Relationship_Company__c = relaIds,  
                                                      Relationship_Tag__c = tagId,
                                                      Parent_Tag_Sharing_Type__c = tag.Sharing_Type__c
                                                    );
            insert newTagItem;
        } catch (Exception e) {
            //SobjectUtility.insertExceptionMessage('ListBuilderController', 'createRelTagItem', e.getMessage());
        }
        return getDynamicQuery(label, '', new List<String>{ relaIds });
    }
    
    /**
     * @description :   Fetches Field API Names and labels from metadata
     *                  Pass the metadata record label to get mapped fields
     * @return : List FieldWrapper
     * @param String (label of List_Builder_Object__mdt record)
     * @info : https://app.clickup.com/t/8406164/IG-1124
    */
    @AuraEnabled 
    public static List<FieldWrapper> getFieldsFromMdt(String label){
        List<FieldWrapper> fieldWrapList = new List<FieldWrapper>();
        if(String.isBlank(label)) return null;  // null check
        try {
            List_Builder_Object__mdt listBuilderObject = [SELECT Id, Label, Object_Api_Name__c, Object_Label__c FROM List_Builder_Object__mdt WHERE Label =: label];

            List<List_Builder_Field__mdt> listBuilderFields = [ SELECT Id, Label, QualifiedApiName, Field_Label__c, Field_API_Name__c, List_Builder_Object__c, Display_Order__c 
                                                                FROM List_Builder_Field__mdt 
                                                                WHERE List_BUilder_Object__r.Label =: listBuilderObject.Label
                                                                ORDER BY Display_Order__c];

            Schema.SObjectType objType;
            if(String.isNotBlank(label)){
                if(label == 'Relationship')
                    objType = Schema.getGlobalDescribe().get('Account');
                else if(label == ''){

                }
            }   
            Map<String, Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
            for(List_Builder_Field__mdt fld : listBuilderFields){
                FieldWrapper obj = new FieldWrapper();
                if(!fld.Field_API_Name__c.containsIgnoreCase('\\.')){
                    if(fields.get(fld.Field_API_Name__c).getDescribe().isAccessible()){ 
                        obj.fieldName = fld.Field_API_Name__c;
                        obj.fieldLabel = fld.Field_Label__c;
                        fieldWrapList.add(obj);
                    }
                }
            }
        } catch (Exception ex) {
            //SobjectUtility.insertExceptionMessage('ListBuilderController', 'getFieldsFromMdt', ex.getMessage());
        }
        return fieldWrapList;
    }

    /**
     * @Method name : getDynamicQuery
     * @description :   returns a list of records related to Object defined in List_Builder_Object__mdt and it's related fields from List_Builder_Field__mdt,
     *                  cannot accept whereClause string param and idList param at once
     * @return : List SObject
     * @param String (label of List_Builder_Object__mdt record)
     * @param String (A where condition to add to query string) - (set to '' if not required)
     * @param List-String (List of Id's to add to query string) - (set to new List<String>() if not required)
     * @info : https://app.clickup.com/t/8406164/IG-1124
    */
    @AuraEnabled 
    public static List<SObject> getDynamicQuery(String label, String whereClause, List<String> idList){
        List<SObject> records = new List<SObject>();
        List<FieldWrapper> fieldWrapList = new List<FieldWrapper>();
        List_Builder_Object__mdt listBuilderObject = new List_Builder_Object__mdt();
        try {
            if(String.isNotBlank(label) ){
                listBuilderObject = [SELECT Id, Object_Api_Name__c FROM List_Builder_Object__mdt WHERE Label =: label];
                fieldWrapList = getFieldsFromMdt(label);
            }
            String query = 'SELECT ';
            if(!fieldWrapList.isEmpty()){
                for(FieldWrapper wrap : fieldWrapList){
                    query += wrap.fieldName + ', ';
                }
            }
            query += 'Id FROM ' + listBuilderObject.Object_Api_Name__c;
            
            if(String.isNotBlank(whereClause))
                query += ' WHERE ' + whereClause;
            else if(String.isBlank(whereClause))
                query += ' WHERE Id IN: idList';

            if(String.isBlank(whereClause) && idList.isEmpty())
                query = query.replace(' WHERE Id IN: idList', ' ');

            if(idList.isEmpty())
                query +=  ' WHERE Id IN: idList';

            records = Database.query(query);
        } catch (Exception ex) {
            //SobjectUtility.insertExceptionMessage('ListBuilderController', 'getDynamicQuery', ex.getMessage());
        }
        return records;
    }

    /**
     * @description :
     * @return : Takes list of Relationship Id's and selected Tag Id and returns all Relationships related to Tag
     * @param String (label of List_Builder_Object__mdt record)
     * @param List_Id (Ids of Relationships from List builder recordList property)
     * @param Id (Id of selected Relationship_Tag__c record)
     * @info : https://app.clickup.com/t/8406164/IG-1130
    */
    @AuraEnabled
    public static UtilityWrapper getData(String label, List<Id> idList, Id tagId){
        UtilityWrapper checkWrap = new UtilityWrapper();
        List<Relationship_Tag_Item__c> tagItems = [SELECT Id FROM Relationship_Tag_Item__c WHERE Relationship_Company__c IN: idList AND Relationship_Tag__c =: tagId];
        
        checkWrap.relationshipExists = tagItems.isEmpty() ? false : true;
        checkWrap.records = getDynamicQuery(label, '', idList);
        return checkWrap;
    }
    
    public class UtilityWrapper{
        @AuraEnabled 
        public Boolean relationshipExists;

        @AuraEnabled 
        public List<SObject> records;

        @AuraEnabled 
        public Id recordId;
    }

    /**
     * @description : To get custom settings related to List Builder
     * @return : List_Builder_Settings__c (Custom Settings for List builder lwc)
     * @info : https://app.clickup.com/t/8406164/IG-1138 
    */
    @AuraEnabled(cacheable=true)
    public static List_Builder_Settings__c getCustomSettings(){
        return List_Builder_Settings__c.getOrgDefaults();
    }
    
    /**
     * @description : To fetch Salesforce base URL domain. In some cases List Builder is opened from VF interface.
     * @return : String (Salesforce Org Domain name)
     */
    @AuraEnabled(cacheable=true)
    public static string getDomain(){
        return System.URL.getOrgDomainUrl().getHost();
    }
}