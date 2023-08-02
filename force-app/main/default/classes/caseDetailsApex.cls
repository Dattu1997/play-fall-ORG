/* *@author           dattu       <anumanlakadidathu@gmail.com>
* @modifiedBy         dattu   <anumanlakadidathu@gmail.com>
* @maintainedBy       dattu   <anumanlakadidathu@gmail.com>
* @version        52.0
* @created        2021-12-10
* @modified      
* @systemLayer     Apex Class
*/ 
public with sharing class caseDetailsApex {
    @AuraEnabled
    public static void caseDetailsApex(Case CaseDetails)
    {
        List<Case> getCase = new List<Case>();
        getCase.add(CaseDetails);
        Insert getCase;        
    }
    @AuraEnabled
    public static void sendMails(String NAME, string EMAIL,string PHONE, string SUBJECT, string DESCRIPTION)
    {
       System.debug('Name : '+NAME);
       String body = 'the name of the person--'+ NAME +'.And his Mail is--'+ EMAIL+'   And his phone number is ='+PHONE+' and he added the subject-- '+SUBJECT+' And description is--' +DESCRIPTION;
       System.debug('tesing the body :' + body);
       Messaging.SingleEmailMessage em =new Messaging.SingleEmailMessage();
       List<User>  adminUserEmail = [SELECT Email FROM user WHERE Profile.Name='System Administrator'];
       List<Messaging.SingleEmailMessage> allEmail = new List<Messaging.SingleEmailMessage>();
       //  // String[] toAddresses = new String[] {adminUserEmail.Email};
       //  System.debug('toaddresses --'+adminUserEmail);
      // List<String> addMail = new List<String>{'srinivas23.midde@gmail.com','pravalikareddy3663@gmail.com'};
      //List<String> addMail = new List<String> {adminUserEmail[0].Email};
     // List<Messaging.Email> allEmail = new List<Messaging.Email>();
      for( User userMail : adminUserEmail)
      {
        em.toAddresses = new String[] {userMail.email};
      }
    //   TA.add(adminUserEmail);
     //  em.setToAddresses(listOfMails);
       
       //List<Messaging.Email> allEmail = new List<Messaging.Email>{em};
       
       em.setSubject('Case Details');
      em.setPlainTextBody(body);
      allEmail.add(em);
        Messaging.sendEmail(allEmail);
     }
   
}