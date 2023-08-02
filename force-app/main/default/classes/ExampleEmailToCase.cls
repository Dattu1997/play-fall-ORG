public class ExampleEmailToCase implements Messaging.InboundEmailHandler {
    private Static Boolean TRACE = true;    
    protected Case theCase = null;
    protected String fromAddress;
    protected Messaging.InboundEmail inboundEmail;
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
                //mail.setDescription = UserName +System.today();
        DateTime dt = DateTime.now();
		String dateTimeStr = dt.format('yyyy/MM/dd hh:mm:ss');
		//System.debug('>>>>' + dateTimeStr);
        mail.setSenderDisplayName(UserInfo.getUserName());
        mail.setDescription(UserInfo.getUserName().substringBefore('@')+' '+dateTimeStr);
        System.debug('Name Of User '+mail);
        System.debug('result '+email.fromAddress);
        try{
            
            result.success = true;
            if(email !=null){
              createNewCase(email);
            }
        }
    		catch(Exception e){
            result.success = false;
            handleError( e,  'Exception while processing InboundEmail');    
            System.debug('Exception '+e.getMessage());
        }
        return result;
    }
        private void createNewCase(Messaging.InboundEmail email){
        System.debug('emailInCreateNewCase '+email);
        //List<String> underWriterEmailsList = getUnderwriterEmails();
        //List<String> pricingDeskEmailsList = getPricingDeskEmails();
        String fromAddrs = email.fromAddress;
        String textbody = email.plainTextBody;
            System.debug('textbody '+textbody.contains('mahesh'));
        //if(String.isNotBlank(textbody) && textbody.contains('>'))
        //textbody = textbody.replaceAll('>', '');
        Contact con =[SELECT Id, Email FROM Contact WHERE Email =:fromAddrs];
        Case theCase = new Case();           
        theCase.SuppliedEmail = fromAddrs;
        theCase.SuppliedName = email.fromName;
        theCase.Priority = 'Normal';
        theCase.Origin = 'Email';
        theCase.Subject = email.Subject;
        theCase.Description = textbody;
        theCase.ContactId = con.Id;
        //cs.ContactId = relatedContactId;
        insertSObject(theCase);
            System.debug('Created case By App : '+theCase);
        if(theCase != null){
            createEmailMessage(theCase,email);
            handleAttachments(theCase, email);
        }
    }
    private void handleAttachments(Case theCase, Messaging.InboundEmail email) {
        System.debug('email '+email);
        if(email.textAttachments!=null && email.textAttachments.size() >0) {            
            List<ContentVersion> cvTextList = new List<ContentVersion>();
            List<ContentDocumentLink> cdlTextList = new List<ContentDocumentLink>();
            for (Messaging.InboundEmail.TextAttachment tAttachment : email.textAttachments) {
                ContentVersion textContentInsert = new ContentVersion();
                textContentInsert.Title = tAttachment.fileName;
                textContentInsert.VersionData = Blob.valueOf(tAttachment.body);
                textContentInsert.PathOnClient = '/' + tAttachment.fileName ;
                cvTextList.add(textContentInsert);                
            }
            insert cvTextList;
            System.debug('cvTextList '+cvTextList);
            cvTextList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvTextList];
            for (ContentVersion cv : cvTextList) {
                ContentDocumentLink cl = new ContentDocumentLink();
                cl.ContentDocumentId = cv.ContentDocumentId;
                cl.LinkedEntityId = theCase.Id; //Shared with record ID
                cl.ShareType = 'V';
                cl.Visibility = 'AllUsers';
                cdlTextList.add(cl);
            }
            insert cdlTextList;
            System.debug('cdlTextList '+cdlTextList);
        }
        
        if(email.binaryAttachments!=null && email.binaryAttachments.size() >0) {
            List<ContentVersion> cvBinaryList = new List<ContentVersion>();
            List<ContentDocumentLink> cdlBinaryList = new List<ContentDocumentLink>();
            for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                ContentVersion binaryContentInsert = new ContentVersion();
                binaryContentInsert.Title = binAttach.fileName;
                binaryContentInsert.VersionData = binAttach.body;
                binaryContentInsert.PathOnClient = '/' + binAttach.fileName;
                cvBinaryList.add(binaryContentInsert);                
            }
            insert cvBinaryList;
            System.debug('cvBinaryList '+cvBinaryList);
            cvBinaryList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvBinaryList];
            for (ContentVersion cv : cvBinaryList) {
                ContentDocumentLink cl = new ContentDocumentLink();
                cl.ContentDocumentId = cv.ContentDocumentId;
                cl.LinkedEntityId = theCase.Id; //Shared with record ID
                cl.ShareType = 'V';
                cl.Visibility = 'AllUsers';
                cdlBinaryList.add(cl);
            }
            insert cdlBinaryList;
        } 
    }
    
    private void createEmailMessage(Case theCase, Messaging.InboundEmail email) {
        System.debug('theCase---EM '+theCase);
        String value;
        Integer maxlength;
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = theCase.Id;
        theEmail.Incoming = true;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());  
        theEmail.TextBody = limitLength(email.plainTextBody,EmailMessage.TextBody.getDescribe().getLength());
        /* **** To */
        value = '';
        if(email.toAddresses != null) {
            Boolean seenOne = false;
            for(String to : email.toAddresses) {
                if(seenOne) {
                    value += ';\n';
                }
                to  = extractAddress(to);
                //System.debug('ToAddress: ' + to);
                value += to;
                seenOne = true;
            }
        }
        theEmail.ToAddress = limitLength(value,EmailMessage.ToAddress.getDescribe().getLength());
        /* **** From */
        theEmail.FromName = email.fromName;
        theEmail.FromAddress = fromAddress;
        /* **** CC */
        value = '';
        if(email.ccAddresses != null) {
            Boolean seenOne = false;
            for(String cc : email.ccAddresses) {
                if(seenOne) {
                    value += ';\n';
                }
                cc  = extractAddress(cc);
                System.debug('CcAddress: ' + cc);
                value += cc;
                seenOne = true;
            }
        }
        theEmail.CcAddress = limitLength(value,EmailMessage.CcAddress.getDescribe().getLength()); 
        
        insertSObject(theEmail);
    }
    private String limitLength(String input, Integer maxLength){
        String results;
        if(input != null && input.length() > maxLength)
            results = input.substring(0,maxLength);
        else 
            results = input;
        return results;
    }
    private void insertSObject(sObject obj) {
        try {insert obj;} 
        catch (System.DmlException e) {handleError(e, 'Could not insert obj '+ obj);}
    }
    //Handle erorrs while inserting sObjects
    @TestVisible
    private void handleError(Exception e,  String message){ //System.DmlException
        System.debug('handleError');
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        if(TRACE)System.debug(baseURL);
        String caseURL;  
        String msg = message + '\n';
        if(this.theCase != null)
        {
            caseURL = baseURL + theCase.Id;
            msg += '\n';
            msg += 'Originating Case Number: ' + theCase.CaseNumber + '  '+ caseURL+'\n';   
        }
        if(this.inboundEmail != null) {
            msg += '\nEmail:';
            msg += '  subject: ' + inboundEmail.Subject + '\n'; 
            msg += '  from: ' + inboundEmail.FromName + '\n'; 
            msg += '  address: ' + fromAddress + '\n'; 
        }
        if(e != null) { // compose the DmlException message on one line to minimize the number of untested lines.  AFAIK easy to instantiate a DmlException in a unit test. 
            msg += '\n';
            msg += 'EXCEPTION:\n  Error: ' + e.getMessage() + '\n  Type: ' + e.getTypeName() + '\n  Line Number: ' + e.getLineNumber() + '\n  Trace:\n' + e.getStackTraceString() + '\n(end stack trace)\n';
        }
        
        Case errCase = new Case();
        //if(storeApplicationId!=null && this.appOwnerId != null){
            //errCase.OwnerId = this.appOwnerId;
            //errCase.Mortgages__c = storeApplicationId;
            //errCase.Status = 'Open';
        //}else if(oppObjId != null && oppOwnerId != null){
           // errCase.Status = 'Closed';
            //errCase.Client_Account__c = this.oppObjId;
            //errCase.IsCMLSServiceEmail__c = true;
            //errCase.OwnerId = this.oppOwnerId;
        //}else if(storeApplicationId == null && oppObjId == null){
            //List<QueueSobject> qsLst = getEmailsToQueue(fromAddress); 
            //if(!qsLst.isEmpty())
            //errCase.OwnerId = qsLst[0].Queue.Id;
           // errCase.Status = 'Open';
        //}
        errCase.Priority = 'Normal';
        errCase.Origin = 'Email';
        errCase.Subject = 'Error processing incoming email';
        //errCase.RecordTypeId = getRecordTypeIdbyName('Case','Email');
        errCase.Description = limitLength(msg,Case.Description.getDescribe().getLength());
        try{
        insert errCase;
        createEmailMessage(errCase,inboundEmail);
        }Catch(DMLException exe){System.debug('Exception while inserting error case : '+exe.getMessage()+'/n'+exe.getStackTraceString());}
    }
    
    private String extractAddress(String inAddress){
        String address;
        String patternString;
        Pattern thePattern;
        Matcher matcher;
        patternString = '.*<(.*)>.*';
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(inAddress);
        if (matcher.matches()) {
            address = matcher.group(1);
            System.debug('Extracted address ' + address); 
        }
        else{
            address = inAddress;
            System.debug('Did not match angle-address ' + address);   
        }
        return address;
    }

}