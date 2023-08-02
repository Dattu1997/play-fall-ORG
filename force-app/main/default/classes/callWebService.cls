public class callWebService {
    private string cKey ='3MVG9pRzvMkjMb6l6UWK_HiA9iVjA8H8qy7VktGXJQzEOCDqTdFLdv5QotBbD57GM1GXAh1GU0tNjheH7k4kl';
    private string cSecret = '50D1373E78BBB7A1CC622EF1BFF1B3D166A4650758085673FD1DABBD5A317EA2';
    private string uName = 'anumanlakadidathu@resourceful-panda-ii7xci.com';
    private string passwd = 'Dattu@12345639ZBHWIJ1At1EldSMLYBD1jWt';
    
    public class responseWrapper {
        public string id;
        public string access_token;
        public string instance_url;
    }
    public string getRequestToken() {
        string reqBody = 'grant_type=password&client_id=' + cKey + '&client_secret=' + cSecret + '&username=' + uName + '&password=' + passwd;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqBody);
        req.setMethod('POST');
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        HttpResponse hresp = h.send(req);
        responseWrapper wResp = (responseWrapper) JSON.deserialize(hresp.getBody(), responseWrapper.class);
        system.debug('Instance url' + wResp.instance_url);
        system.debug('session id' + wResp.access_token);
        return wResp.access_token;
    }
    @AuraEnabled
   // @future(callout = true)
    public static void getConList(string firstName,string lastName,string phone,string email,string recordId) {
        system.debug('conObj'+firstname+lastname+phone+email);
        String accToken;
        string responseBody;
        string endPoint = 'https://resourceful-panda-ii7xci-dev-ed.my.salesforce.com/services/apexrest/createContactRecord';
        callWebService obj = new callWebService();
        accToken = obj.getRequestToken();
        system.debug('access token' + accToken);
        if (accToken != '') {
            contact con = new contact();
            con.FirstName = firstName;
            con.LastName = lastName;
            con.Phone = phone;
            con.Email = email;
            
            
            
            
          //  for (Contact con: [SELECT id, firstName, lastName, email from contact where id =: conIdSet]) {
                system.debug('JSON' + JSON.serialize(con));
                Http h1 = new Http();
                HttpRequest req1 = new HttpRequest();
                req1.setHeader('Authorization', 'Bearer ' + accToken);
                req1.setHeader('Content-Type', 'application/json');
                req1.setMethod('POST');
                req1.setBody(JSON.serialize(con));
                req1.setEndpoint(endPoint);
                HttpResponse hresp1 = h1.send(req1);
                system.debug('hresp1' + hresp1);
                getOppList(firstName+' '+lastName,date.today(),'Qualification');
            //}
        }
    }
    @future(callout = true)
    public static void getOppList(string Name,date CloseDate,string StageName) {
        //system.debug('conObj'+firstname+lastname+phone+email);
        String accToken;
        string responseBody;
        string endPoint = 'https://resourceful-panda-ii7xci-dev-ed.my.salesforce.com/services/apexrest/createContactOpport';
        callWebService obj = new callWebService();
        accToken = obj.getRequestToken();
        system.debug('access token' + accToken);
        if (accToken != '') {
           Opportunity opp = new Opportunity();
            //opp.AccountId = recordId1;
            opp.Name = Name;
            opp.CloseDate = CloseDate;
            opp.StageName = StageName;  
            
            
            
            
          //  for (Contact con: [SELECT id, firstName, lastName, email from contact where id =: conIdSet]) {
                //system.debug('JSON' + JSON.serialize(opp));
                Http h2 = new Http();
                HttpRequest req2 = new HttpRequest();
                req2.setHeader('Authorization', 'Bearer ' + accToken);
                req2.setHeader('Opportunity-Type', 'application/json');
                req2.setMethod('GET');
                req2.setBody(JSON.serialize(opp));
                req2.setEndpoint(endPoint);
                HttpResponse hresp1 = h2.send(req2);
            
            
            Opportunity opp1 = new Opportunity();
            //opp1.AccountId = recordId1;
            opp1.Name = Name;
            opp1.CloseDate = CloseDate;
            opp1.StageName = StageName;
                        
               // system.debug('hresp1' + hresp1);
            //}
            insert opp1;
        }
        
    }
  
}