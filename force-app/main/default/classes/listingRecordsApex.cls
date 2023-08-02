/*
@author        A dattu        <anumanlakadidathu@playful-wolf-cz3uwx.com>
 * @modifiedBy     A dattu       <anumanlakadidathu@playful-wolf-cz3uwx.com>
 * @maintainedBy   A dattu        <anumanlakadidathu@playful-wolf-cz3uwx.com>
 * @version        52.0
 * @created        2021-12-14
 * @modified      
 @systemLayer    Apex Class 
 */
public with sharing class listingRecordsApex
 {
     //fetching values from custom listing object in lwc
  
    //This Method is used to retrieve the data fromm listing recording. 
    @AuraEnabled
    Public static string savelistingRecords(Listing__c listingDetails, string file, string fileName){
      string listId;
    try{
        insert listingDetails;
        listId = listingDetails.Id;
        String base64File = EncodingUtil.urlDecode(file, 'UTF-8');
        ContentVersion contentVersionRec = new ContentVersion();
        contentVersionRec.Title = fileName;
        contentVersionRec.PathOnClient = '/' + fileName;
        contentVersionRec.FirstPublishLocationId = listingDetails.Id;
        contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);
        contentVersionRec.IsMajorVersion = true;
        Insert contentVersionRec;
      } catch(Exception ex){
        system.debug('Exception===>'+ex.getMessage());
      }
      return listId;
    }

    @AuraEnabled
    public static List<String> getCategoryPickList()
    {
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> categoryPickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry eachOne : categoryPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<string> getStatusPickList(){
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> categoryPickList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachOne : categoryPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<string> getStatePickList(){
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.State2__c.getDescribe();
        List<Schema.PicklistEntry> categoryPickList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachOne : categoryPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<string> getDurationPickList(){
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Duration__c.getDescribe();
        List<Schema.PicklistEntry> categoryPickList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachOne : categoryPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
}