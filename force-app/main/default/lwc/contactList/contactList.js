import { LightningElement, api, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactListController.getContacts';

const columns = [
    {label : 'Name' , fieldName : 'Name', type : 'text'},
    {label : 'Email', fieldName : 'Email', type : 'email'}
];
export default class ContactList extends LightningElement {
    @api recordId;
    @track data = [];
    columns = columns;

    connectedCallback(){

        getContacts({accId : this.recordId})
        .then(result =>{
            console.log('result: ',result);
            this.data = [...result];
        }).catch(error =>{
            console.log('error ',error);
        })
    }

}