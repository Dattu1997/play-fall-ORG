public class contactBatchable implements Database.Batchable<sObject> {
    
public Database.QueryLocator start(Database.BatchableContext BC){
    String query ='SELECT Id,FirstName,Email,AccountId,Phone FROM contact';
       return Database.getQueryLocator(query);
   }
    
    
    
   public void execute(Database.BatchableContext BC, List<contact> scope){
       System.debug('the gdhfhjg===='+scope);
       List<contact> conList = new List<contact>();
       for(contact con : scope ){
           con.FirstName = 'S121212112';
           con.Email = 'dattu@gmail.com';
           con.Phone = '213232342';
           conList.add(con);
       }
       update conList;
       
   } 
    
    
    
    public void finish(Database.BatchableContext BC){
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'anumanlakadidathu@gmail.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Wellcome to Batch ');
            mail.setPlainTextBody(' Batch apex class is finished ');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   }
    
}