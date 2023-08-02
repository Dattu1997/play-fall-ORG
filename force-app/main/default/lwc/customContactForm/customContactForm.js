import { LightningElement, api } from 'lwc';
// import { createRecord } from 'lightning/uiRecordApi';
// import conMainObject from '@salesforce/schema/Contact';
// import conFirstName from '@salesforce/schema/Contact.FirstName';
// import conLastName from '@salesforce/schema/Contact.LastName';
// import conPhone from '@salesforce/schema/Contact.Phone';
// import conEmail from '@salesforce/schema/Contact.Email';
// import conDepartment from '@salesforce/schema/Contact.Department';
// import conDescription from '@salesforce/schema/Contact.Description';
import getConList from '@salesforce/apex/callWebService.getConList';
//import getOppList from '@salesforce/apex/callWebService.getOppList';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
//import ConvertedAccountId from '@salesforce/schema/Lead.ConvertedAccountId';
export default class CustomContactForm extends LightningElement {
   //@api recordId; 
   @api firstName ;
   @api lastName ;
   @api phoneNo ;
   @api emailId ;
    //departmentVal=''
    //descriptionVal='';
 
    contactChangeVal(event) {
        // if(FirstName !==null && lastName !==null && phoneNo !==null && emailId !==null){
            if(event.target.label == 'First Name'){
            this.firstName = event.target.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('firstName', this.firstName));
            
        }
        if(event.target.label == 'Last Name'){
            
            this.lastName = event.target.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('lastName', this.lastName));
        }            
        if(event.target.label == 'Phone'){
            
            this.phoneNo = event.target.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('phoneNo', this.phoneNo));
        }
        if(event.target.label == 'Email'){
            this.emailId = event.target.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('emailId', this.emailId));
           // callApex()
        }
        // if(event.target.label =='recordId'){
        //     this.recordId = event.target.value;
        //     this.dispatchEvent(new FlowAttributeChangeEvent('recordId', this.emailId));
        // }
        if(this.firstName !=null && this.lastName !=null && this.phoneNo !=null && this.emailId !=null){
                
       
        getConList({firstName:this.firstName, lastName:this.lastName, phone:this.phoneNo, email:this.emailId});
        //getOppList({Name:this.firstName+''+this.lastName,CloseDate:this.date.today(),StageName:this.StageName,recordId:this.recordId});
    }
    }
   // if(event.target.label=='Department'){


        //     this.departmentVal = event.target.value;
        // }
        // if(event.target.label=='Description'){
        //     this.descriptionVal = event.target.value;
        // }
//  callApex(){
// getConList({firstname :this.firstName,lastname :this.lastName,phone :this.phoneNo,email : this.emailId});
    
//  }
    
 
 
    // insertContactAction(){
    //     console.log(this.selectedAccountId);
    //     const fields = {};
    //     fields[conFirstName.fieldApiName] = this.firstName;
    //     fields[conLastName.fieldApiName] = this.lastName;
    //     fields[conPhone.fieldApiName] = this.phoneNo;
    //     fields[conEmail.fieldApiName] = this.emailId;
    //     fields[conDepartment.fieldApiName] = this.departmentVal;
    //     fields[conDescription.fieldApiName] = this.descriptionVal;
    //     console.log('fields-->' + fields);
    //     console.log('record-->' + recordInput);
    //     const recordInput = { apiName: conMainObject.objectApiName, fields };
        
    //     createRecord(recordInput)
    //     //getConList(recordInput)
    //     //fetchAccount(recordInput)
    //         .then(contactobj=> {
    //             getConList({conIdSet :contactobj.id})
    //             this.contactId = contactobj.id;
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Contact record has been created',
    //                     variant: 'success',
    //                 }),
    //             );
    //             this[NavigationMixin.Navigate]({
    //                 type: 'standard__recordPage',
    //                 attributes: {
    //                     recordId: contactobj.id,
    //                     objectApiName: 'Contact',
    //                     actionName: 'view'
    //                 },
    //             });
 
 
 
    //         })
    //         .catch(error => {
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error creating record',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                 }),
    //             );
    //         });
            
    // } 
}