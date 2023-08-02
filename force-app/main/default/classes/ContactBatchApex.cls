public  class ContactBatchApex implements Database.batchable<sObject>,Schedulable{
    public Database.QueryLocator Start(Database.BatchableContext bc ){
        String query = 'SELECT Id,Name,Email,Birthdate FROM Contact WHERE Email != null AND Birthdate != null';
        System.debug('StartMethod'+query);
        return database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        Date d = date.parse(date.today().addDays(7).format());
        Integer day;
        Integer month;
        Integer d1 = d.day();
        Integer m1 = d.month();
        System.debug('Date'+ d);
        for(Contact con : scope){
         day = con.Birthdate.day();
         month = con.Birthdate.month();
         if(day == d1 && month == m1){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] address = new List<string>{con.Email};
                mail.setToAddresses(address);
                mail.setSubject('Hi dattu Wish U Very Happy Birthday');
                mail.setPlainTextBody('Hi This is Dattu');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('Mail'+mail);
         }
        }
    }
        public void finish(Database.BatchableContext BC){
            
              //runBatch();              
         }
    
     public void execute(SchedulableContext sc)

     {
         
    ContactBatchApex reminder = new ContactBatchApex();
         
         Database.executeBatch(reminder);
         
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            
           
     }
    
    //public static void runBatch(){
        
        //ContactBatchApex reminder2 = new ContactBatchApex();
        
        //String sch = '0 0 22 * * ? *';
            //String jobID = System.schedule('Remind Opp Owners', sch, reminder2);
         
         //system.debug('fheuishfsiddfj'+jobID);
        
    //}
    
}