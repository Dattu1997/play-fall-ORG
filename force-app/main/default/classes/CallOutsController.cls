public class CallOutsController {
    @InvocableMethod(label = 'APICallout' callout = 'true')
    public static void callOutMethod(List<String> test) {
        Http htp = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://th-apex-http-callout.herokupp.com');
        req.setMethod('GET');
        HttpResponse res  = htp.send(req);
        System.debug('res---'+res.getBody());
    }
}