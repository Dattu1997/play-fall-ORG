global class CreateCaseFromMail implements Messaging.InboundEmailHandler {
    global static Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope envelope){
     Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
       String myPlainText= '';
    String value = System.Label.Case_Origin;
    // Store the email plain text into the local variable 
    myPlainText = email.plainTextBody;
  
    // Create a new Case object 
   List <Case> newCase = new list <Case>();
   
    // Try to look up any contacts based on the from email address.
    // If there are more than one contacts with the same email address,
    // an exception will be thrown and the catch statement block will be executed.
try 
{
     Contact Con = [SELECT Id, Name, Email FROM Contact WHERE Email = :email.fromAddress   LIMIT 1];
      
      // Add a new Case to the contact record we just found above.
      newCase.add(new Case(Description =  myPlainText,
           Priority = 'Normal',
           Status = 'Inbound Email',
           Subject = email.subject,
           Origin = value,                
           ContactId = Con.Id                
           ));
     
     // Insert the new Case 
     insert newCase;    
     
     System.debug('New Case Object: '+newCase);   
    }
    // If an exception occurs when the query accesses 
    // the contact record, a QueryException is thrown.
    // The exception is written to the Apex debug log.
   catch (QueryException e) {
       System.debug('Query Issue: ' + e);
   }
        result.success = true;
   
   // Return the result for the Apex Email Service
   return result;
    }
}