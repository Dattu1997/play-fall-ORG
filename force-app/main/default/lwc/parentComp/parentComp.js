import { LightningElement } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class parentComp extends LightningElement {
 contactValues = {};

  fields = [{ fieldapi: 'LastName', fieldtype: 'text', label: 'LastName', iseditable: true },
  { fieldapi: 'Email', fieldtype: 'email', label: 'Email', iseditable: true },
  { fieldapi: 'Phone', fieldtype: 'phone', label: 'Phone', iseditable: false },
  { fieldapi: 'Title', fieldtype: 'text', label: 'Title', iseditable: true},
  { fieldapi: 'Birthdate', fieldtype:'date', label: 'Birthdate', iseditable: true},
  { fieldapi: 'Department', fieldtype:'text',label: 'Department', iseditable: false},
  ]

  getContactValues(event) {
    var label = event.detail.label;
    var value = event.detail.value;
    this.contactValues.sObjectType = 'Contact';

    this.contactValues[label] = value;
    // if (label == 'Name') {
    //   this.contactValues.LastName = value;
    //   console.log(this.contactValues.LastName);
    // }
    // else if (label == 'Email') {
    //   this.contactValues.Email = value;
    //   console.log(this.contactValues.Email);
    // }  
    // else if (label == 'Title') {
    //   this.contactValues.Title = value;
    // }
    // else if (label == 'BirthDate') {
    //   this.contactValues.Birthdate = value;
    //   console.log(this.contactValues.Birthdate);
    // }
    //   
    
    // this.contactValues.sObjectType = 'Contact';
  }
    submitDetails(event) {
      this.contactValues.Phone = '6234158371';
      this.contactValues.Department = 'ECE';
       getContacts({conDetails: this.contactValues})
      .then(() => {
        this.dispatchEvent(
        new ShowToastEvent({
        title: 'Success',
        message: 'Contact is created',
        variant: 'success',
        }),
    );
     });
    }
 }