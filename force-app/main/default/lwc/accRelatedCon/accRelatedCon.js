import { LightningElement,api,track,wire } from 'lwc';
import getAccounts from '@salesforce/apex/LookUpLwcController.getAccounts';
import retriveAccountsData from '@salesforce/apex/LookUpLwcController.retriveAccountsData';
import deleteContacts from '@salesforce/apex/LookUpLwcController.deleteContacts';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
const columns = [
    {label: 'FirstName', fieldName: 'FirstName', type: 'text'},
    {label: 'LastName', fieldName: 'LastName', type: 'text'},
    {label: 'Email', fieldName: 'Email', type: 'Email'},
    {label: 'Phone', fieldName: 'Phone', type: 'Phone'},
    
];
export default class AccRelatedCon extends LightningElement {
    @track accountId = '';
    @track contacts;
    @track columns = columns;
    @track deleteConatctIds = '';
    @track selectedRec = [];
    selectedAcc ={};
    //con;
    //acc;
    //  invoke apex method with wire property and fetch picklist options.
    // pass 'object information' and 'picklist field API name' method params which we need to fetch from apex
    @wire(getAccounts) accounts;
    onValueSelection(event) {
        const selectedAccount = event.target.value;
        this.selectedAcc = selectedAccount;
        console.log('selectedAcc ',this.selectedAcc);
        this.accountId = event.target.value;
        if (selectedAccount != null) {
            retriveAccountsData({
                    accountId: selectedAccount
                })
                .then(result => {
                    this.contacts = result;
                    console.log('this.contacts ',+ JSON.stringify(this.contacts) + selectedAccount);
                    console.log('result' + JSON.stringify(result) + selectedAccount);
                })
                .catch(error => {
                    this.error = error;
                });
        }
        
    }
    
    handleRowAction(event){
        this.selectedRec = event.detail.selectedRows;
        console.log('selectedRec '+JSON.stringify(this.selectedRec));
    }
    removeContacts(){
        console.log('In remove Contact--');
        deleteContacts({con : this.selectedRec, acc : this.selectedAcc})
                .then( result => {
                console.log('result2--- ',result);
                    
                }).catch( error => {
                    console.log(error);
                });
    }
}