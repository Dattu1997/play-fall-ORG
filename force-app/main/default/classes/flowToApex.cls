public with sharing class flowToApex {
    public static void flowToApex() {
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId','00B5j000007zKeQEAU');
        system.debug('ParamsNames::: '+Params);
        //create instance of Interview
        Flow.Interview.ApexFlowClass stage = new Flow.Interview.ApexFlowClass(Params);
        
        //Invoke start method
        stage.start();
        
        //get value from Flow
        Object stageName=stage.getvariableValue('record');
        system.debug('stageName::: '+stageName);
    }
}