
public class accessTokenWithConnectedApp {
    
    static string cKey ='3MVG9pRzvMkjMb6mUa0VHg3xN8kRuqrR2VKuwWnwL01cMUC3bVa1ifVQrRNmwZHoQG2so_C5tPaxQVYJA2UtW';
    static string cSecret = 'C7624BAACA347470ED7787C3860C507725A8BCF123BDE2F685684A071482AC78';
    static string uName = 'anumanlakadidathu@playful-wolf-cz3uwx.com';
    static string passwd = 'Dattu@098741t8DkKgY4T7Pjq9dKzW5dkd';
    
    public class responseWrapper {
        public string id;
        public string access_token;
        public string instance_url;
    }

    @AuraEnabled
    public static string getRequestToken() {
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
}
