public class ContactEmail {
    public static void emailContact() {
        List<Contact> con = [SELECT Id,Name, Email,Birthdate FROM Contact WHERE Email != null AND Birthdate != null];
        Date d = Date.parse(date.today().addDays(7).format());
        Integer bm;
        Integer bd;
        Integer m = d.month();
        Integer day = d.day();
        String dayy = String.valueOf(day);
        System.debug('day'+dayy);
        
        for(Contact conObj : con){
             bd = conObj.Birthdate.day();
             bm = conObj.Birthdate.month();
             if(bd == day && bm == m){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] address = new List<string>{conObj.Email};
                mail.setToAddresses(address);
                mail.setSubject('Hi dattu Wish U Very Happy Birthday');
                mail.setPlainTextBody('Hi This is Dattu');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


                 
             }
             System.debug('conObj'+conObj);
             
        }
        
        
        
        
 
            
 
        
        
    }
}