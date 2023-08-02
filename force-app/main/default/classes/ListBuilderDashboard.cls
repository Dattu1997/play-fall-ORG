public with sharing class ListBuilderDashboard {
    public string query{get; set;}
 
/* To determine the records to perform the bulk action on, extract the SAQL query */
    public PageReference init() {
        query = ApexPages.currentPage().getParameters().get('query');
        System.debug('query--'+query);
        String isTrue = ApexPages.currentPage().getParameters().get('isTrue');
        if(query != null){
            query = query.replaceAll('\"', '%22');
        }
        String urlDomain = 'https://' + System.URL.getOrgDomainUrl().getHost(); 
        PageReference pageRef = new PageReference(urlDomain + '/one/one.app#/alohaRedirect/apex/ListBuilderActionContainer?isTrue=1&query='+query);
        pageRef.setRedirect(true);
        pageRef.setRedirectCode(301);
        if(isTrue != '1')
            return pageRef;
        else
            return null;
    }

/* Takes the account records from the SAQL query, creates an opportunity for each account, and then returns a map between account ID and new opportunity name. Note: Account.Name and AccountId referenced below refer to the dataset field names. Update them to match your dataset fields. */
    @RemoteAction
    public static Map<String, String> create(List <Map<String, String>> accountRecords) {
        system.debug('starting create...: ');        
        Map<String, String> result = new Map<String, String>();

        List<Opportunity> opps = new List<Opportunity>();
        for (Map<String, String> accountRecord : accountRecords) {
            system.debug('accountRecord: ' + accountRecord);        
            String name = accountRecord.get('NAME') + ' - Sprint Review - 12/2';
            String accountId = accountRecord.get('SF_ID');
                result.put(accountId, name);
                System.debug('result-'+result);
            Opportunity opp = new Opportunity(
/* You can set different fields from the Opportunity object than those listed below, like Amount. */
                Name = name,
                Type ='New Customer',
                AccountId = Id.valueOf(accountId),
                CloseDate=Date.valueOf('2016-12-31'),
                StageName='Prospecting'); 
            opps.add(opp);
        }
//        insert opps;
        return result;
    }
}