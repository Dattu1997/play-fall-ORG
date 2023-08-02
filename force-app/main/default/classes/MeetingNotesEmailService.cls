public  class MeetingNotesEmailService implements Messaging.InboundEmailHandler{

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try{
            EmailUtility EU = new EmailUtility();
            //EU.processMeetingNotes(email); 
            
            
            //EmailUtility.validatePeActivityId('Inbound Email',peActivity, email);                     

            result = EU.processOutboundEmail(email);
            
        }
            catch(Exception e){
            result.success = false;
                
            System.debug('Exception '+e.getMessage());
        }
        return result;
    }
}