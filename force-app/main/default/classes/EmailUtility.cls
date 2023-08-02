public  class EmailUtility {
    // public static final String iconiqDomain = 'iconiqcapital.com';
    // public static String emailSubject;
    public static final String ICONIQ_EMAIL_DOMAIN = 'iconiqcapital.com';
    public static final String PE_ACTIVITY_TYPE_OUTBOUND_EMAIL = 'Email - Outbound';
    public static final String PROCESS_OUTBOUND_EMAIL = 'Outbound Email';
    public static final String PE_INVOLVEMENT_FOLLOW_UP = 'Follow Up';
    public static final String PE_INVOLVEMENT_INITIAL = 'Initial';
    public static final String RECORD_TYPE_EMPLOYER_COMPANY = 'Employer_Company';
    public static final String INDUSTRY_TECHNOLOGY = 'Technology';
//  public static final String ORG_WIDE_EMAIL_DISPLAY_NAME = 'Outbound Email Exception Sender';
    public static final String EXCEPTION_EMAIL_TEMPLATE = 'Outbound Email Exception';
    public static final String OUTBOUND_NO_MATCH_EMAIL_TEMPLATE = 'Outbound Email No Match';
    public static final String CEO = 'Chief Executive Officer';
    public static final String CONFIRMATION_EMAIL_TEMPLATE = 'Outbound Email Confirmation';
    

    /**
	 * Method Name : processOutboundEmail
	 * @description :
	 * @return : InboundEmailResult - result
	 * @param : InboundEmail - email
	*/
	public Messaging.InboundEmailResult processOutboundEmail(Messaging.InboundEmail email){
		System.debug('In Outbound Email---');
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		List<User> userList = [SELECT Id FROM USER WHERE Email =: email.fromAddress]; // fetching User from email from: address
		System.debug('userList--'+userList);
		try {
			PE_Activity__c peActivity = new PE_Activity__c(	Type__c = PE_ACTIVITY_TYPE_OUTBOUND_EMAIL,
															Subject__c = email.subject,
															ActivityDate__c = Date.today(),
															Owner__c = !userList.isEmpty() ? userList[0].Id : null
														  );
			
			populateDescription(PROCESS_OUTBOUND_EMAIL, peActivity, email); // populate Description__c field.
			
			/* 
			*PE_Activity_Participant will be inserted after PE_Activity's PE_Involvement field is populated 
			*/
			List<PE_Activity_Participant__c> peActivityParticList = addPeActivityParticipants(peActivity, email);
            
			addPeContactsAndRelationship(peActivity, email); 	//fetching Contact and related Account or only Account based on email's to: and cc: addresses

			peActivity.PE_Opportunity__c = isInitialOrFollowup(peActivity);		//if Account found, populating PE_Opportunity__c with 'Follow Up' and if not with null

			//EmailMessageTriggerHandler.setRecursiveFlag(true); 	//set the recursive flag on the EmailMessage trigger handler to bypass logic to auto-create a PE Activity for outbound email
			insert peActivity;
			

			if(peActivity.Relationship__c == null){
				sendExceptionEmail(peActivity, 'Outbound Email - no match', email);		//sends email to from: User when no Contact/Relationship is found.
			}else if(peActivity.Relationship__c <> null)
				sendConfirmationEmail(peActivity, email);								//sends email to from: user when a PE Activity is created
			
			addAttachments(peActivity, email);		//adding email attachments to newly created PE_Activity__c record
			
			
			if(!peActivityParticList.isEmpty() && peActivityParticList != null){
				for(PE_Activity_Participant__c peActivityParticipant : peActivityParticList){
					peActivityParticipant.PE_Activity__c = peActivity.Id;
				}
				insert peActivityParticList;		//inserting PE_Activity_Participant__c records.
			}

			addEmbeddedImages(peActivity, email);	//add embedded images to email body

			result.success = true;
		} catch (Exception ex) {
			System.debug('processOutboundEmail exception : ' + ex.getMessage());
			result.message = ex.getMessage();
			result.success = false;
		}
		return result;
	}

	/**
	 * Method name : validatePeActivityId
	 * @description : To verify whether a valid PE_Activity__c Id exists in email body. If not sends mail.
	 * @return : PE_Activity__c
	 * @param : String
	 * @param : PE_Activity__c
	 * @param : InboundEmail
	*/
	/*public static PE_Activity__c validatePeActivityId(String Type, PE_Activity__c peActivity, Messaging.InboundEmail email) {
		List<String> fromAdd = new List<String>{email.fromAddress};
		User usr = [SELECT Id FROM User WHERE UserName =: email.fromAddress];
		String peActivityId = peActivity.Id;
		String emailBody = getEmailBody(email);
		Map<Id, PE_Activity__c> peActivityMap = new Map<Id, PE_Activity__c>([SELECT Id FROM PE_Activity__c]);
		if(emailBody.contains(peActivityId)){
			if(peActivityMap.containsKey(peActivityId)){
				peActivity = peActivityMap.get(peActivityId);
				return peActivity;
			}else{
				
				Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
				sendMail.setSubject('(Email Sync) *ACTION NEEDED* ' +'['+ Date.today() + ']' +'['+ email.subject + ']');
				sendMail.setToAddresses(fromAdd);
				sendMail.setPlainTextBody('['+Date.today()+'] - ['+ email.subject+']' + '/br'+
											'A PE Activity record has been created for the email referenced above.'+ 
											'However, the Contact and/or Relationship could not be associated with the PE Activity due to missing records in Salesforce.'+
											' To resolve, follow the link below and associate the correct Contact and/or Relationship records with the PE Activity.');
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sendMail});
				return null;
			}
		}else{
			Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
			sendMail.setSubject('Error processing PE Activity');
			sendMail.setToAddresses(fromAdd);
			sendMail.setPlainTextBody('There was an error while processing PE Activity. ID: ' + peActivity.Id + '.');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sendMail});
			return null;
		}
	}*/

	/**
	 * Method name : isInitialOrFollowup
	 * @description : To populate the picklist value for PE_Opportunity__c based on PE_Activity Relationship.
	 * @return : String ('Follow Up' || null)
	 * @param : PE_Activity__c (Takes peActivity record before insert and populates it's related PE_Oppurtunity__c field)
	 * @tags : processOutboundEmail
	*/
	public static String isInitialOrFollowup(PE_Activity__c peActivity) {
		
		if(peActivity.Relationship__c != null){
			List<PE_Activity__c> peActivityList = [SELECT Id FROM PE_Activity__c WHERE Relationship__c =: peActivity.Relationship__c];
			if(peActivityList.size() > 0 && !peActivityList.isEmpty())
				return PE_INVOLVEMENT_FOLLOW_UP;
			else
				return PE_INVOLVEMENT_INITIAL;
		}
		else
			return null;
	}

	/**
	 * Method Name : populateDescription
	 * @description : Populates the Description__c field with email htmlBody or plainTextBody.
	 * @return : void
	 * @param : String - Type ('Outbound Email' || 'Meeting Notes')
	 * @param : PE_Activity__c - peActivity (to populate Description__c field)
	 * @param : InboundEmail - email (to get both htmlBody and plainTextBody)
	 * @tags : processOutboundEmail
	*/
	public static void populateDescription(String Type, PE_Activity__c peActivity, Messaging.InboundEmail email){
		System.debug('email html body length---'+email.htmlBody.length());
        string htmlBody = email.htmlBody.subString(0, 50).stripHtmlTags();
        
        System.debug('htmlBody--'+ htmlBody);
		String UserName = UserInfo.getName();
		String DescriptionHeader = UserName +' : ' + String.valueOf(System.now());
		
		if(Type == PROCESS_OUTBOUND_EMAIL){
			peActivity.Description__c = email.htmlBody != null ? htmlBody : email.plainTextBody;
		}
		else if(Type == 'Meeting Notes'){
			peActivity.Description__c = DescriptionHeader+ '\r\n' + '---------'  + '\r\n' +
										email.plainTextBody;
		}
	}
	
	/**
	 * Method Name : addAttachments
	 * @description : To get email attachments and save as a file linked to PE_Activity__c.
	 * @return : void
	 * @param : PE_Activity__c - peActivity (to get email attachments and attach to peActivity.)
	 * @param : InboundEmail - email (to get both text and binary attachments from email)
	 * @tags : processOutboundEmail
	*/
	public static void addAttachments(PE_Activity__c peActivity, Messaging.InboundEmail email){
		
		Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments != null ? email.textAttachments : null;
		Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.binaryAttachments != null ? email.binaryAttachments : null;
		List<ContentVersion> cvList = new List<ContentVersion>();
		List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
		
		
		try {
			if(tAttachments != null && tAttachments.size() > 0){
				for(Messaging.InboundEmail.TextAttachment textAttachment : tAttachments){
				  ContentVersion cv = new ContentVersion();
				  cv.Title = textAttachment.fileName;
				  cv.VersionData = Blob.valueOf(textAttachment.body);
				  cv.PathOnClient = '/'+ textAttachment.fileName;
				  cvList.add(cv);
			  }
		  	}
			if(bAttachments != null && !bAttachments.isEmpty()){
				for(Messaging.InboundEmail.BinaryAttachment binaryAttachment : bAttachments){
					ContentVersion cv = new ContentVersion();
					cv.Title = binaryAttachment.fileName;	
					cv.VersionData = binaryAttachment.body;
					cv.PathOnClient = '/' + binaryAttachment.fileName;
					cvList.add(cv);
				}
			}
			if(!cvList.isEmpty()) insert cvList;      	//inserting content version of both Text and binary Attachment
			
			
			cvList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvList];
			for(ContentVersion cvObj : cvList){
				ContentDocumentLink cl = new ContentDocumentLink();
				cl.ContentDocumentId = cvObj.ContentDocumentId;
				cl.LinkedEntityId = peActivity.Id;
				cl.shareType = 'V';
				cdLinkList.add(cl);
			}
			insert cdLinkList;        //inserting content document link and attaching file to peActivity record.
			
		} catch (Exception ex) {
			System.debug('ContentVersion DML exception: '+ ex.getMessage());
			System.debug('Exception : '+ ex);
			Exception__c excep = new Exception__c(Class__c = 'EmailUtility', Method__c = 'addAttachments', Message__c = ex.getMessage(), Sobject_API_Name__c = peActivity.Id);
			insert excep;
			sendExceptionEmail(peActivity, 'Outbound Email Exception', email);		//send email to salesforce team
		}
	}

	/**
	 * Method name : addEmbeddedImages
	 * @description : This method adds embedded images to the email body that were received as attachments
	 * @return : void
	 * @param : PE_Activity__c - peActivity
	 * @param : InboundEmail - email
	 * @tags : processOutboundEmail
	 */
	public static void addEmbeddedImages(PE_Activity__c peActivity, Messaging.InboundEmail email) {
		
		String srcOld = '';
		String srcNew = '';
		List<Id> conDocLinkIdList = new List<Id>();
		List<String> altList = new List<String>();
		Map<String, List<String>> mapAltToSrc = new Map<String, List<String>>();

		for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: peActivity.Id]){
			conDocLinkIdList.add(conDocLink.ContentDocumentId);
		}
		String fileExt = '';
		for(Email_Settings__c emailSettings : [SELECT Id, Name, Image_File_Extensions__c FROM Email_Settings__c]){
			if(emailSettings.Image_File_Extensions__c != null){
				fileExt = emailSettings.Image_File_Extensions__c.toUpperCase();
			}
		}
		List<String> fileExtensions = fileExt.split(';');
		System.debug('fileExtensions---- '+ fileExtensions);

		List<ContentVersion> conVersList = [SELECT Id, ContentBodyId, ContentDocumentId, Title, FileType FROM ContentVersion WHERE FileType IN: fileExtensions AND ContentDocumentId IN :conDocLinkIdList ORDER BY Id];
		System.debug('conVerList: '+ conVersList);
		System.debug('email htmlBody--- '+ email.htmlBody);
		List<String> listSrc = new List<String>();
		if(email.htmlBody.contains('<img')){
			List<String> htmlBodyList = email.htmlBody.split('<img');
			for(String htmlString : htmlBodyList){

				System.debug('htmlString: '+ htmlString);
				String src = htmlString.subString(htmlString.indexOf('src')+5, htmlString.indexOf('>')-1);
				
				System.debug('src--- '+ src);
				if(!src.contains('https://'))
					listSrc.add(src);
				System.debug('listSrc--- '+ listSrc);
			}
		}
		Integer count = 1;		//Start count at 1 instead of 0; the first segment in lstSrc will include the html that appears prior to the first img tag
		for(ContentVersion conVer : conVersList){
			System.debug('in else');
			System.debug('fileType: '+ conVer.FileType + ' ID: '+conVer.Id + ' bodyId: '+ conVer.ContentBodyId);
			if(listSrc <> null && listSrc.size() > 0 && count < listSrc.size()){
				srcOld = listSrc[count];
				srcNew =URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+ conVer.FileType +'&versionId='+ conVer.Id +'&operationContext=CHATTER&contentId=' + conVer.ContentBodyId;
				count++;
				System.debug('Description1: '+peActivity.Description__c);
				peActivity.Description__c = peActivity.Description__c.Replace(srcOld, srcNew);	
				System.debug('Description2: '+peActivity.Description__c);
			}
		}
		
		try {
			update peActivity;
		} catch (Exception ex) {
			
			System.debug('exception while updating peActivity: '+ ex.getMessage());
			Exception__c excep = new Exception__c(Class__c = 'EmailUtility', Method__c = 'addEmbeddedImages', Message__c = ex.getMessage(), Sobject_API_Name__c = peActivity.Id);
			insert excep;
			sendExceptionEmail(peActivity, 'Outbound Email Exception', email);		//send email to salesforce team
		}
	}

	/**
	 * Method name : addPeActivityParticipants
	 * @description : create PE_Activity_Participant__c if email to: address or cc: address has iconiq User and User's PE_Activity_User__c is checked
	 * @return : List PE_Activity_Participant__c
	 * @param : PE_Activity__c - peActivity
	 * @param : InboundEmail - email
	 * @tags : processOutboundEmail
	*/
	public static List<PE_Activity_Participant__c> addPeActivityParticipants(PE_Activity__c peActivity, Messaging.InboundEmail email) {
		
		List<PE_Activity_Participant__c> peActivityPartList = new List<PE_Activity_Participant__c>();
		List<User> userList = new List<User>();
		String userLevel = '';
		
		List<String> allAddresses = getEmailByDomain(email, true);    // to get all emails where domain equals @iconiqcapital.com
		allAddresses.add(email.fromAddress);
		System.debug('allAddresses--'+allAddresses);

		if(!allAddresses.isEmpty() && allAddresses.size() > 0)
			userList = [SELECT Id, Email, PE_Activity_User__c, Level__c FROM User WHERE Email IN: allAddresses AND PE_Activity_User__c = true AND Level__c != null ORDER BY Level__c DESC];
		
		System.debug('userList-'+userList);
		userLevel = !userList.isEmpty() ? userList[userList.size() -1].Level__c : null;
		
		peActivity.PE_Involvement__c = userLevel;		// populating PE_Involvement__c
		
		if(!userList.isEmpty() && userList.size() > 0){
			for(User u : userList){
				
				if(!email.fromAddress.contains(u.Email)){
					
					PE_Activity_Participant__c peActivityPart = new PE_Activity_Participant__c();
					peActivityPart.Participant__c = u.Id;
					peActivityPartList.add(peActivityPart);
				}
			}
		}
		
		
		return peActivityPartList;
	}

	/**
	 * Method name : addPeContactsAndRelationship
	 * @description :
	   Main method for getting Contacts and Relationships to assign to PE_Activity__c record.
	   Querying Communication__c records using SOSL (Email__c is encrypted) and passing to getMatchingContact()
	 * @return : void
	 * @param : PE_Activity__c - peActivity (To assign Contact and Relationship)
	 * @param : InboundEmail - email (To fetch non-iconiq emails from to: and cc: addresses)
	 * @tags : processOutboundEmail
	*/
	public static void addPeContactsAndRelationship(PE_Activity__c peActivity, Messaging.InboundEmail email){
		
		List<Communication__c> communicationList = new List<Communication__c>();		//To store Communication__c records from SOSL
		
		List<String> emailList = getEmailByDomain(email, false); //To store emails where domain <> @iconiqcapital.com
		

		if(!emailList.isEmpty() && emailList.size() > 0){	//IG-1178 - skip this section if there are no emails on the To: or cc: list
			String emails = String.join(emailList, ' OR ');
			
			//List<List<Communication__c>> commRecords = [FIND :emails IN ALL FIELDS returning Communication__c
													//	(Email__c, Relationship__c, Contact__c, Relationship__r.RecordTypeId, Relationship__r.Industry, Relationship__r.Website, Contact__r.Id, Contact__r.Title
														//WHERE Type__c = 'Business' AND Active__c = 'Yes')];
			List<Communication__c> communiList = [Select Id, Email__c, Relationship__r.RecordTypeId, Relationship__r.Industry, Relationship__r.Website, Contact__r.Id, Contact__r.Title FROM Communication__c WHERE Type__c = 'Business' AND Active__c = 'Yes'];
            System.debug('communiList---'+communiList);
			for(Communication__c commList : communiList){
				communicationList.add(commList);
			}
			System.debug('communicationList: '+ communicationList);
			/* if(Test.isRunningTest()){
				communicationList = [SELECT Id, Email__c, Relationship__c, Contact__c, Relationship__r.RecordTypeId, Relationship__r.Industry, Relationship__r.Website, Contact__r.Id, Contact__r.Title
										FROM Communication__c WHERE Type__c = 'Business' AND Active__c = 'Yes'];
			} */
			
			
			Communication__c matchingContact = getMatchingContact(peActivity, communicationList);		//Passing Communication__c records to get single match. If not, find Ceo Contact.
			
				
			if(matchingContact <> null){
				peActivity.Who__c = matchingContact.Contact__c;
				peActivity.Relationship__c = matchingContact.Relationship__c;
				peActivity.Email_To_Address__c = matchingContact.Email__c;
			}
			else {
				List<String> toAddresses = getEmailByDomain(email);
				for(String toAddress : toAddresses){
					if(toAddress.length() <= 80){
						peActivity.Email_To_Address__c = toAddress;
						break;
					}
				}
				// peActivity.Email_To_Address__c = toAddresses[0];
				findPeRelationshipByDomain(peActivity, emailList, email);		//finding Account relation using email domains matching Account Website value.
			}
		}
	}

	/**
	 *Method name : getMatchingContact
	 * @description : 
	 * @return : Communication__c - (Returns a single Communication__c record if found else calls getCeoContact() by passing CommunicationList)
	 * @param : PE_Activity__c - peActivity
	 * @param : List Communication__c - communicationList
	 * @tags : addPeContactsAndRelationships
	*/
	public static Communication__c getMatchingContact(PE_Activity__c peActivity, List<Communication__c> communicationList){
		
		List<Communication__c> matchingCommunicationList = new List<Communication__c>();
		List<Communication__c> ceoContactList = new List<Communication__c>();
		Map<String, List<Communication__c>> mapContactsByEmail = new Map<String, List<Communication__c>>();

		
		// Account Employer/Company RecordTypeId.
		Id accEmpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_EMPLOYER_COMPANY).getRecordTypeId();
		
		
		
		for(Communication__c comm : communicationList){
			if(mapContactsByEmail.containsKey(comm.Email__c)){
				List<Communication__c> commsList = mapContactsByEmail.get(comm.Email__c);
				commsList.add(comm);
				mapContactsByEmail.put(comm.Email__c, commsList);
			}else {
				mapContactsByEmail.put(comm.Email__c, new List<Communication__c>{comm});
			}
			if(comm.Relationship__r.RecordTypeId == accEmpRecTypeId && comm.Relationship__r.Industry == INDUSTRY_TECHNOLOGY){
				matchingCommunicationList.add(comm);
			}
		}
		
		
		
		if(matchingCommunicationList.size() == 1) return matchingCommunicationList[0];		

		
		ceoContactList = getCeoContact(matchingCommunicationList);
		
		if(!ceoContactList.isEmpty() && ceoContactList.size() > 0){		//fetching Ceo Contact.......

			if(ceoContactList.size() == 1) return ceoContactList[0];

			else if(!mapContactsByEmail.isEmpty()){
				for(String strEmail : mapContactsByEmail.keySet()){		//iterate mapContacteByEmail map Email values

					if(mapContactsByEmail.get(strEmail).size() == 1){		//checking if email has no duplicate contacts
	
						if(ceoContactList.contains(mapContactsByEmail.get(strEmail)[0])){
							return ceoContactList[0];
						}
					}
					if(mapContactsByEmail.get(strEmail).size() == 1){
						return mapContactsByEmail.get(strEmail)[0];
					}
				}
			}
		
			//If no matching contact found, iterate ceoContactList.
			for(Communication__c communication : ceoContactList){
				if(communication.Contact__r.Email <> null){
					if(communication.Relationship__r.Website == communication.Contact__r.Email.split('@')[1])
						return communication;
				}
				else
					return ceoContactList[0];
			}
		}
		
		//If no Ceo Contact match found, iterate matchingCommunicationList, if there is a duplicate return it
		if(!matchingCommunicationList.isEmpty() && matchingCommunicationList.size() > 0 ){

			
			
			if(!mapContactsByEmail.isEmpty()){
				for(String strEmail : mapContactsByEmail.keySet()){		//iterate mapContactsByEmail map Email values

					if(mapContactsByEmail.get(strEmail).size() == 1){		//checking if email has no duplicate contacts
	
						if(matchingCommunicationList.contains(mapContactsByEmail.get(strEmail)[0])){		//checking if Contact from map is in matchingCommunicationList
	
							return matchingCommunicationList[0];
						}
					}
					
					
					if(mapContactsByEmail.get(strEmail).size() == 1){
						return mapContactsByEmail.get(strEmail)[0];
					}
				}

				for(Communication__c matchComm : matchingCommunicationList){
					if(matchComm.Email__c <> null){
						if(matchComm.Relationship__r.Website == matchComm.Email__c.split('@')[1])		//checking Account website value with Email domain
							return matchComm;
					}
				}		
				return matchingCommunicationList[0];
			}
		}
		
		
		return null;
	}

	/**
	 * Method name : getCeoContact
	 * @description : 
	 * @return : List Communication__c - matchingCeoContacts
	 * @param : List Communication__c - commsList
	 * @tags : getMatchingContact
	*/
	public static List<Communication__c> getCeoContact(List<Communication__c> commsList){
		
		List<Communication__c> matchingCeoContacts = new List<Communication__c>();
		Map<Id, List<Contact_Tag__c>> mapContactTags = new Map<Id, List<Contact_Tag__c>>();	 //Populate with Contact Id's to List<Contact_Tag__c>
		Map<Id,List<Communication__c>> communContactsMap = new Map<Id,List<Communication__c>>();

		for(Communication__c comm : commsList){
			communContactsMap.put(comm.Contact__r.Id, new List<Communication__c>{comm});
		}
		
		for(Contact_Tag__c contName : [SELECT Id, Contact_Name__c, Contact_Name__r.Id, value__c 
										FROM Contact_Tag__c 
										WHERE Contact_Name__c IN: communContactsMap.keyset() 
										AND value__c =: CEO])
		{
			if(mapContactTags.containsKey(contName.Contact_Name__r.Id)){
				List<Contact_Tag__c> contTagList = mapContactTags.get(contName.Contact_Name__r.Id);
				contTagList.add(contName);
				mapContactTags.put(contName.Contact_Name__r.Id, contTagList);
			}else {
				mapContactTags.put(contName.Contact_Name__r.Id, new List<Contact_Tag__c> {contName});
			}
		}																					
		

		if(!commsList.isEmpty()){
			for(Communication__c communication : commsList){
				if(mapContactTags.containskey(communication.Contact__c))
					matchingCeoContacts.add(communication);
			}
			if(matchingCeoContacts.isEmpty()){
				for(Communication__c comm : commsList){
					
					if(comm.Contact__r.Title == 'CEO' || comm.Contact__r.Title == CEO){
						matchingCeoContacts.add(comm);
					}
				}
			}	
		}
		
		return matchingCeoContacts;
	}

	/**
	 * @method name : findPeRelationshipByDomain
	 * @description : to fetch Accounts by matching Website values with domains from to: and cc: addresses from InboundEmail.
	 * @return : Account
	 * @param : PE_Activity__c - peActivity (To assign Account record)
	 * @param : List String - emailList (all non-iconiq cc: and to: email addresses)
	 * @tags : addPeContactsAndRelationship
	*/
	public static Account findPeRelationshipByDomain(PE_Activity__c peActivity, List<String> emailList, Messaging.InboundEmail email) {
		
		List<String> domainList = new List<String>(); 		// To add only email domains
		List<Account> accList = new List<Account>();
		String domain = '';
		if(!emailList.isEmpty()){
			for(String strEmail : emailList){
				if(strEmail.contains('@')){
					domain = '%' + strEmail.split('@').get(1) + '%';
					domainList.add(domain);
				}
			}
		}
		
		List<Account> matchingRelationships = [SELECT Id,Website FROM Account WHERE Website LIKE :domainList AND RecordType.DeveloperName =: RECORD_TYPE_EMPLOYER_COMPANY AND Industry =: INDUSTRY_TECHNOLOGY];
		

		for(Account acc : matchingRelationships){		//iterating all Accounts to filter websites

			System.Url websiteUrl = new Url(acc.Website);		//convert string to Url
			String hostName = websiteUrl.getHost();
			
			if(hostName.startsWithIgnoreCase('www.'))
				hostName = hostName.removeStartIgnoreCase('www.');
			
			if(domainList.contains('%' + hostName + '%'))
				accList.add(acc);
			
		}
		
		

		if(accList.size() == 1){
			peActivity.Relationship__c  = accList[0].Id;
			return accList[0];
		}
		else{
			return null;
		}
	}

	/**
	 * Method name : sendExceptionEmail
	 * @description : To send an email to from Address user if an error occurs while processing PE_Activity__c.
	 * @return : void
	 * @param : PE_Activity__c - peActivity (To get Id of the rec to include in email body)
	 * @param : String - exceptionType ('Outbound Email - no match') , ('Outbound Email Exception')
	 * @param : InboundEmail - email (To get from address and subject)
	 */
	public static void sendExceptionEmail(PE_Activity__c peActivity, String exceptionType,Messaging.InboundEmail email){
		
		
		// OrgWideEmailAddress orgWideAddrss = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: ORG_WIDE_EMAIL_DISPLAY_NAME];

		// Exception__c excep = [SELECT Id, Name, Class__c, Method__c, Message__c FROM Exception__c WHERE Sobject_API_Name__c =: peActivity.Id].size() > 0 
		// 					? [SELECT Id, Name, Class__c, Method__c, Message__c FROM Exception__c WHERE Sobject_API_Name__c =: peActivity.Id]
		// 					: null;

		Messaging.SingleEmailMessage sendMail = new Messaging.SingleEmailMessage();
		Set<String> templateNames = new Set<String>{ OUTBOUND_NO_MATCH_EMAIL_TEMPLATE, EXCEPTION_EMAIL_TEMPLATE };
		
		for(EmailTemplate emTemp : [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Name IN: templateNames]){
		
			if(emTemp.Name == OUTBOUND_NO_MATCH_EMAIL_TEMPLATE && exceptionType == 'Outbound Email - no match'){
				Id tempId = emTemp.Id;
				String emailBody = emTemp.Body;
				String emailSubject = emTemp.Subject;
				if(emTemp.Subject.containsIgnoreCase('<<Date>>'))
					emailSubject = emailSubject.Replace('<<Date>>', Date.today().format());
				if(emTemp.Subject.containsIgnoreCase('<<Email Subject>>'))		
					emailSubject = emailSubject.Replace('<<Email Subject>>', email.subject);
				if(emTemp.Body.containsIgnoreCase('<<Date>>'))
					emailBody = emailBody.Replace('<<Date>>', Date.today().format());
				if(emTemp.Body.containsIgnoreCase('<<Email Subject>>'))
					emailBody = emailBody.Replace('<<Email Subject>>', email.subject);
				if(emTemp.Body.containsIgnoreCase('<<LINK TO THE PE ACTIVITY RECORD>>'))	
					emailBody = emailBody.Replace('<<LINK TO THE PE ACTIVITY RECORD>>', URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/PE_Activity__c/' + peActivity.Id +'/view');
				if(emailBody.containsIgnoreCase('<<RelationshipLink>>'))
					emailBody = emailBody.replace('<<RelationshipLink>>', peActivity.Relationship__c != null ? URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Account/' + peActivity.Relationship__c + '/view' : '');
				if(emailBody.containsIgnoreCase('<<ContactLink>>'))
					emailBody = emailBody.replace('<<ContactLink>>', peActivity.Who__c != null ? URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Contact/' + peActivity.Who__c + '/view' : '');
				if(emailBody.containsIgnoreCase('<<AssignedTo>>'))
					emailBody = emailBody.replace('<<AssignedTo>>', UserInfo.getName());
				if(emailBody.containsIgnoreCase('<<ActivityType>>'))
					emailBody = emailBody.replace('<<ActivityType>>', peActivity.Type__c = peActivity.Type__c != null ? peActivity.Type__c : '');
				if(emailBody.containsIgnoreCase('<<PE_Involvement>>'))
					emailBody = emailBody.replace('<<PE_Involvement>>', peActivity.PE_Involvement__c = peActivity.PE_Involvement__c != null ? peActivity.PE_Involvement__c : '');
				if(emailBody.containsIgnoreCase('<<PE_Opportunity>>'))
					emailBody = emailBody.replace('<<PE_Opportunity>>', peActivity.PE_Opportunity__c = peActivity.PE_Opportunity__c != null ? peActivity.PE_Opportunity__c : '');

				// sendMail.setOrgWideEmailAddressId(orgWideAddrss.Id);
				sendMail.setTemplateId(tempId);
				sendMail.setSubject(emailSubject);
				sendMail.setToAddresses(new List<String>{ email.fromAddress });
				sendMail.setPlainTextBody(emailBody);
			}
			else if(emTemp.Name == EXCEPTION_EMAIL_TEMPLATE && exceptionType == EXCEPTION_EMAIL_TEMPLATE){
				Id tempId = emTemp.Id;
				String emailBody = emTemp.Body;
				String emailSubject = emTemp.Subject;
				
				if(emTemp.Subject.containsIgnoreCase('<<Date>>'))
					emailSubject = emailSubject.Replace('<<Date>>', Date.today().format());
				if(emTemp.Subject.containsIgnoreCase('<<Email Subject>>'))	
					emailSubject = emailSubject.Replace('<<Email Subject>>', email.subject);
				if(emTemp.Body.containsIgnoreCase('<<Email Subject>>'))
					emailBody = emailBody.replace('<<Email Subject>>', email.subject);
				if(emTemp.Body.containsIgnoreCase('<<Date>>'))
					emailBody = emailBody.Replace('<<Date>>', Date.today().format());
				// if(emTemp.Body.containsIgnoreCase('{!Exception__c.Class__c}'))
				// 	emailBody = emailBody.replace('{!Exception__c.Class__c}', excep.Class__c);
				// if(emTemp.Body.containsIgnoreCase('{!Exception__c.Method__c}'))
				// 	emailBody = emailBody.replace('{!Exception__c.Method__c}', excep.Method__c);
				// if(emTemp.Body.containsIgnoreCase('{!Exception__c.Message__c}'))
				// 	emailBody = emailBody.replace('{!Exception__c.Message__c}', excep.Message__c);
				
				sendMail.setTemplateId(tempId);
				//sendMail.setToAddresses(new List<String>{ System.Label.SalesforceOutboundEmailService });
				sendMail.setSubject(emailSubject);
				sendMail.setPlainTextBody(emailBody);
			}
		}
		// if(sendMail != null)
		// 	sendEmailMessages( new List<Messaging.SingleEmailMessage>{ sendMail });
	}

	/**
	 * Method name : getEmailBody
	 * @description : Returns email body (plainTextBody & HtmlBody)
	 * @return : String - emailBody
	 * @param : InboundEmail - mail (Inbound email from external user).
	 * tags : validatePeActivityId
	*/
	public static String getEmailBody(Messaging.InboundEmail email){
		String emailBody = '';
		if(!String.isBlank(email.plainTextBody))
			emailBody = email.plainTextBody;
		else if(!String.isBlank(email.HtmlBody)){
			emailBody = email.HtmlBody.stripHtmlTags();
		}	
		return emailBody;
	}

	/**
	 * Method name : getEmailByDomain
	 * @description :
	  Utility method to get mails based on domain from Inbound email.
	  Here we are checking the domain value from Email_Settings__c custom settings.
	  To get iconiq mails set isIconiq Boolean to true and false to get non iconiq mails 
	 * @return : List<String> returns a list of iconiq or non-iconiq emails.
	 * @param : InboundEmail - email (an inbound email from external user).
	 * @param : Boolean - isIconiq (set to true or false)
	 * @tags : addPeActivityParticipants ; addPeContactsAndRelationship
	*/
	public static List<String> getEmailByDomain(Messaging.InboundEmail email, Boolean isIconiq){
        System.debug('in getEmailByDomain---');
		List<String> emailList = new List<String>();
		List<String> allEmailsList = new List<String>();
		Domain_Email__c emailSettings = [SELECT Id, Name, ICONIQ_Email_Domain__c FROM Domain_Email__c LIMIT 1];
        System.debug('emailSettings--'+emailSettings);
		String iconiqEmailDomain = emailSettings.ICONIQ_Email_Domain__c;
        
		if(email.toAddresses != null){					//IG-1178
			allEmailsList.addAll(email.toAddresses);
		}
		if(email.ccAddresses != null){
			allEmailsList.addAll(email.ccAddresses);
		}
		
		for(String allAddress : allEmailsList){
			if(isIconiq){
				if(allAddress.containsIgnoreCase(iconiqEmailDomain))
					emailList.add(allAddress);	
			}
			else if(!allAddress.containsIgnoreCase(iconiqEmailDomain))
				emailList.add(allAddress);
                System.debug('allAddress---'+allAddress);
		}	
		return emailList;
	}
	
	public static List<String> getEmailByDomain(Messaging.InboundEmail email) {
		List<String> toAddresses = new List<String>();
		Domain_Email__c emailSettings = [SELECT Id, Name, ICONIQ_Email_Domain__c FROM Domain_Email__c LIMIT 1];
		String iconiqEmailDomain = emailSettings.ICONIQ_Email_Domain__c;
		if(email.toAddresses != null){
			for(String toEmail : email.toAddresses){
				if(!toEmail.contains(iconiqEmailDomain))
					toAddresses.add(toEmail);
			}
		}
		return toAddresses;
	}

	/**
	 * @method name : sendConfirmationEmail
	 * @description : To send a confirmation email to from: user when a PE_Activity is successfully created
	 * @param PE_Activity__c (Newly inserted Pe Activity record)
	 * @param Messaging.SingleEmailMessage (Inbound Email)
	 * @info : https://app.clickup.com/t/8406164/IG-1179
	*/
	public static void sendConfirmationEmail(PE_Activity__c peActivity, Messaging.InboundEmail email){
		EmailTemplate emailTemp = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name = :CONFIRMATION_EMAIL_TEMPLATE];

		String relationshipLink = peActivity.Relationship__c != null ? URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Account/' + peActivity.Relationship__c + '/view' : '';
		String contactLink = peActivity.Who__c != null ? URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Contact/' + peActivity.Who__c + '/view' : '';

		if(emailTemp.Subject.containsIgnoreCase('<<Date>>'))
			emailTemp.Subject = emailTemp.Subject.replace('<<Date>>', Date.today().format());
		if(emailTemp.Subject.containsIgnoreCase('<<Email Subject>>'))
			emailTemp.Subject = emailTemp.Subject.replace('<<Email Subject>>', email.Subject);
		if(emailTemp.Body.containsIgnoreCase('<<Date>>'))
			emailTemp.Body = emailTemp.Body.replace('<<Date>>', Date.today().format());
		if(emailTemp.Body.containsIgnoreCase('<<Email Subject>>'))
			emailTemp.Body = emailTemp.Body.replace('<<Email Subject>>', email.Subject);
		if(emailTemp.Body.containsIgnoreCase('<<LINK TO THE PE ACTIVITY RECORD>>'))
			emailTemp.Body = emailTemp.Body.replace('<<LINK TO THE PE ACTIVITY RECORD>>', URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/PE_Activity__c/' + peActivity.Id + '/view');
		if(emailTemp.Body.containsIgnoreCase('<<RelationshipLink>>'))
			emailTemp.Body = emailTemp.Body.replace('<<RelationshipLink>>', relationshipLink);
		if(emailTemp.Body.containsIgnoreCase('<<ContactLink>>'))
			emailTemp.Body = emailTemp.Body.replace('<<ContactLink>>', contactLink);
		if(emailTemp.Body.containsIgnoreCase('<<AssignedTo>>'))
			emailTemp.Body = emailTemp.Body.replace('<<AssignedTo>>', UserInfo.getName());
		if(emailTemp.Body.containsIgnoreCase('<<ActivityType>>'))
			emailTemp.Body = emailTemp.Body.replace('<<ActivityType>>', peActivity.Type__c = peActivity.Type__c != null ? peActivity.Type__c : '');
		if(emailTemp.Body.containsIgnoreCase('<<PE_Involvement>>'))
			emailTemp.Body = emailTemp.Body.replace('<<PE_Involvement>>', peActivity.PE_Involvement__c = peActivity.PE_Involvement__c != null ? peActivity.PE_Involvement__c : '');
		if(emailTemp.Body.containsIgnoreCase('<<PE_Opportunity>>'))
			emailTemp.Body = emailTemp.Body.replace('<<PE_Opportunity>>', peActivity.PE_Opportunity__c = peActivity.PE_Opportunity__c != null ? peActivity.PE_Opportunity__c : '');

		Messaging.SingleEmailMessage confirmEmail = new Messaging.SingleEmailMessage();
		confirmEmail.setTemplateId(emailTemp.Id);
		confirmEmail.setToAddresses(new List<String>{ email.fromAddress });	
		confirmEmail.setSubject(emailTemp.Subject);
		confirmEmail.setPlainTextBody(emailTemp.Body);

		//sendEmailMessages(new List<Messaging.SingleEmailMessage>{ confirmEmail });
	}

}