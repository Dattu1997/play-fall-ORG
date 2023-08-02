/* *@author       A Dattu        <anumanlakadidathu@gmail.com>
* @modifiedBy     A Dattu        <anumanlakadidathu@gmail.com>
* @maintainedBy   A Dattu        <anumanlakadidathu@gmail.com>
* @version        52.0
* @created        2021-12-12
* @modified      
* @systemLayer     Apex Class
*/ 
public with sharing class CaseDetailController {
    @AuraEnabled
    //caseRecordDetailsApex method is retriving the details 
    public static void caseRecordDetails(Case CaseDetails,String NAME, string EMAIL,string PHONE, string SUBJECT, string DESCRIPTION)
    {
       List<Case> getCase = new List<Case>();
       getCase.add(CaseDetails);
       Insert getCase;        
       System.debug('Name : '+NAME);
       String body = 'the name of the person--'+ NAME +'.And his Mail is--'+ EMAIL+'   And his phone number is ='+PHONE+' and he added the subject-- '+SUBJECT+' And description is--' +DESCRIPTION;
       System.debug('tesing the body :' + body);
       Messaging.SingleEmailMessage em =new Messaging.SingleEmailMessage();
       List<User>  adminUserEmail = [SELECT Email FROM user WHERE Profile.Name='System Administrator'];
       List<Messaging.SingleEmailMessage> allEmail = new List<Messaging.SingleEmailMessage>();
       
      for( User userMail : adminUserEmail)
      {
        em.toAddresses = new String[] {userMail.email};
      }
    
       
       em.setSubject('Case Details');
      em.setPlainTextBody(body);
      allEmail.add(em);
        Messaging.sendEmail(allEmail);
     }
   
}