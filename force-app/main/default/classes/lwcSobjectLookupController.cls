/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class lwcSobjectLookupController  {

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, 
                                        string objectName, String filter, Boolean callingFromGridEditUtility,
                                        Boolean respectSRules, Boolean isUseSOSL, String orderBy,
                                        String recordLimit, Boolean isTypeListBuilder, List<String> fieldsToDisplay, String whereClause) 
    {
        System.debug('isTypeListBuilder: '+ isTypeListBuilder);
        System.debug('fieldsToDisplay: '+ fieldsToDisplay);
        System.debug('whereClause: '+ whereClause);
        // System.debug('valuesrecodrs --> '+valuesrecodrs);
        Integer DataLimit = 0;
        
        if(String.isNotBlank(recordLimit)){
            DataLimit = Integer.valueOf(recordLimit);
        }else{
            DataLimit = 50;
        }
        if(!callingFromGridEditUtility){
            String myQuery = null;
            Set<String> sOBjectsSet = new Set<String>{'RecordType'};
            System.debug('searchTerm '+searchTerm);
            if(filter != null && filter != '')
            {
                if(sOBjectsSet.contains(objectName)){
                    myQuery = 'Select Id, Name from '+objectName+' Where ' +filter+' LIMIT  5';
                    System.debug('1- '+myQuery);
                }else{
                    myQuery = 'Select Id, Name from '+objectName+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
                }
                
            }
            else {
                if(searchTerm == null || searchTerm == ''){
                    if(sOBjectsSet.contains(objectName)){
                        myQuery = 'Select Id, Name from '+objectName+' Where LastModifiedDate != NULL ORDER BY LastModifiedDate DESC LIMIT  5';
                    }
                    else if(objectName == 'Account' && isTypeListBuilder){
                        myQuery = 'Select Id, '+ fieldsToDisplay.toString().removeStart('(').removeEnd(')') +' from '+objectName+' Where '+ whereClause + ' AND Name Like \'%'+searchTerm+'%\' LIMIT  5';
                    }
                    else{
                        myQuery = 'Select Id, Name from '+objectName+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5'; 
                    }
                }
                else {
                    if(objectName == 'Account' && isTypeListBuilder && searchTerm != null){
                        myQuery = 'Select Id, '+ fieldsToDisplay.toString().removeStart('(').removeEnd(')')  +' from '+objectName+' Where ' + whereClause + ' AND Name Like \''+searchTerm+'%\' ORDER BY Name ASC';
                    }
                    else{
                        myQuery = 'Select Id, Name from '+objectName+' Where Name Like \'%'+searchTerm+'%\' LIMIT  5';
                        System.debug('51- '+myQuery);
                    }
                }
            }
            System.debug(myQuery);
            List<sObject> lookUpList = database.query(myQuery);
            Set<Id> idSet = new Set<Id>();
            for(sObject s : lookUpList){
                idSet.add(s.Id);
            }
            if(lookUpList.size() > 5){
                List<sObject> idOfSet = new List<sObject>();
                for(Integer i= 0; i < 5; i++){
                    idOfSet.add(lookUpList[i]);  
                }
                return idOfSet;
            }
            else if(objectName == 'Account' && isTypeListBuilder && searchTerm != null && (lookUpList.size() < 5)){
                Integer l = 5 - lookUpList.size();
                myQuery = 'Select Id, '+ fieldsToDisplay.toString().removeStart('(').removeEnd(')')  +' from '+objectName+' Where ' + whereClause + ' AND Name Like \'%'+searchTerm+'%\' '+' AND Id NOT IN: idSet ORDER BY Name ASC LIMIT: l';
                List<sObject> lookUpList1 = database.query(myQuery);
                lookUpList.addAll(lookUpList1);
            }
            return lookUpList;
        }else{

            if(String.isNotBlank(searchTerm) && searchTerm.length() > 2){
                return lookupSearchForGridEditUtility(searchTerm, objectName, filter, respectSRules, isUseSOSL, orderBy, DataLimit);
            }else{
                return new List<sObject>();
            }
            
        }
        
    }

    @AuraEnabled
    public static List<SObject> lookupSearchForGridEditUtility(String searchString, String sObjectAPIName, String filterCondition, Boolean respectSharingRules, Boolean isUseSOSL, String orderBy, Integer recordLimit){


        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

		List<SObject> results = new List<SObject>();

        if(isUseSOSL){
            // Build our SOSL query
            String searchQuery = prepareSoslQuery(searchString, sObjectAPIName, filterCondition, respectSharingRules, sanitizedSObjectAPIName, sanitizedSearchString, orderBy, recordLimit);
            
            system.debug(searchQuery);
            if( respectSharingRules ){
                // Execute the Query
                List<List<SObject>> searchList = search.query(searchQuery);
                results = searchList[0];
                // Create a list of matches to return
                /*for (SObject so : searchList[0]){
                    if(sanitizedSObjectAPIName == 'Case'){
                        results.add(new Result((String)so.get('CaseNumber'), so.Id));
                    }else{
                        results.add(new Result((String)so.get('Name'), so.Id));
                    }
                }*/
            }else{
                LookupSearchWithoutSharing lsws = new LookupSearchWithoutSharing();
                results = lsws.getAllRecords(searchQuery, sanitizedSObjectAPIName, true);
            }
        }else{
            String searchQuery = prepareSoqlQuery(searchString, sObjectAPIName, filterCondition, respectSharingRules, sanitizedSObjectAPIName, sanitizedSearchString, orderBy, recordLimit);

            if( respectSharingRules ){
                results = Database.query(searchQuery);
            }else{
                LookupSearchWithoutSharing lsws = new LookupSearchWithoutSharing();
                results = lsws.getAllRecords(searchQuery, sanitizedSObjectAPIName, false);
            }
        }
        
        
        //results.sort();
        return results;
    }

    static String prepareSoqlQuery(String searchString, String sObjectAPIName, 
                                    String filterCondition, Boolean respectSharingRules, 
                                    String sanitizedSObjectAPIName, String sanitizedSearchString, String orderBy, Integer recordLimit)
    {
        String searchQuery = ' SELECT ' ;
        if(sanitizedSObjectAPIName == 'Case'){
            searchQuery +=  ' Id,CaseNumber ';
        }else{
            searchQuery += ' Id,Name ';
        }

        searchQuery += ' FROM ' + sanitizedSObjectAPIName + ' ';

        if( filterCondition == '' || filterCondition == null ){
            if( sanitizedSObjectAPIName == 'User' ){
                filterCondition = ' WHERE IsActive = true ';

            }
        }
        if( filterCondition != '' && filterCondition != null ){
            searchQuery += filterCondition;

            if(String.isNotBlank(sanitizedSearchString)){
                sanitizedSearchString = '\'%' + sanitizedSearchString + '%\'';
                if(sanitizedSObjectAPIName == 'Case'){
                    searchQuery += ' AND CaseNumber LIKE ' + sanitizedSearchString;
                }else{
                    searchQuery += ' AND Name LIKE '+ sanitizedSearchString;
                }
                
            }
        }else{
            if(String.isNotBlank(sanitizedSearchString)){
                sanitizedSearchString = '\'%' + sanitizedSearchString + '%\'';
                if(sanitizedSObjectAPIName == 'Case'){
                    searchQuery += ' WHERE CaseNumber LIKE ' + sanitizedSearchString;
                }else{
                    searchQuery += ' WHERE Name LIKE '+ sanitizedSearchString;
                }
                
            }
        }
        
        if(String.isNotBlank(orderBy)){
            searchQuery += ' ORDER BY  ' + orderBy;
        }else{
            if(sanitizedSObjectAPIName == 'Account'){
                searchQuery += ' ORDER BY  Name';
            }
        }
        
        if(recordLimit != null){
            searchQuery += ' Limit ' + recordLimit; 
        }else{
            searchQuery += ' Limit 50 '; 
        }

        System.debug('searchQuery====' + searchQuery);
        return searchQuery;
    }

    static String prepareSoslQuery(String searchString, String sObjectAPIName, String filterCondition, 
                                    Boolean respectSharingRules, String sanitizedSObjectAPIName, 
                                    String sanitizedSearchString, String orderBy, Integer recordLimit){
        String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' ;
        if(sanitizedSObjectAPIName == 'Case'){
            searchQuery += sanitizedSObjectAPIName + '(Id,CaseNumber ';
        }else{
            searchQuery += sanitizedSObjectAPIName + '(Id,name ';
        }
        if( filterCondition == '' || filterCondition == null ){
            if( sanitizedSObjectAPIName == 'User' ){
                filterCondition = ' WHERE IsActive = true ';
            }
        }
        if( filterCondition != '' && filterCondition != null ){
            searchQuery += filterCondition;
        }
        
        if(String.isNotBlank(orderBy)){
            searchQuery += ' ORDER BY  ' + orderBy;
        }else{
            if(sanitizedSObjectAPIName == 'Account'){
                searchQuery += ' ORDER BY  Name';
            }
        }
        
        
        searchQuery += ') ';

        if(recordLimit != null){
            searchQuery += ' Limit ' + recordLimit; 
        }else{
            searchQuery += ' Limit 50 '; 
        }
        
        System.debug('orderBy====' + orderBy);
        System.debug('recordLimit====' + recordLimit);

        return searchQuery;
    }
    
    public without sharing class LookupSearchWithoutSharing{
 		
        public List<SObject> getAllRecords( String searchQuery, String sObjectAPIName , Boolean isUseSOSL){
                             
            if(isUseSOSL){
                // Execute the Query
                List<List<SObject>> searchList = search.query(searchQuery);
                return searchList[0];
            }else{
                return Database.query(searchQuery);
            }
		 
		}
    }

}