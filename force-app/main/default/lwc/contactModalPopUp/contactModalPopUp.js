import { LightningElement, track, api } from 'lwc';
import getContactSaved from '@salesforce/apex/ContactModalPopUpController.getContactSaved';
export default class ContactModalPopUp extends LightningElement {
    isModalOpen = false;
    contactDetails;
    @api contactLookUp;
    error;
    @track lastName = '';
    @track emailval = '';

    getContactVal(event){
        this.lastName = event.target.value;
    }
    getEmailVal(event){
        this.emailval = event.target.value;
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    
    handleSave(){
        getContactSaved({lastName : this.lastName, email : this.emailval})
        .then(result =>{
            console.log('result----- ',result);
            this.contactDetails = result;
            console.log('this.contactDetails ',this.contactDetails);
        }).catch(error =>{
            this.error = error;
        })
        this.lastName = '';
        this.emailval= '';
    }
    
}