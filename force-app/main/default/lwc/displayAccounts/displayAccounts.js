import { LightningElement,wire,track } from 'lwc';
import getDataFromContact from '@salesforce/apex/getAccounts.getDataFromContact';

const columns=[

    {
    
    label: 'View',                        
    
    type: 'button',
    
    initialWidth: 45,
    
    typeAttributes: {
    
    // <!--iconName: 'action:preview',-->
    label: 'View', 
    title: 'View',
    
    variant: 'border-filled',
    
    alternativeText: 'View'
    
    }
    
    
    },
    
    
    
    {
    
    label: 'First Name',
    
    fieldName: 'FirstName'
    
    },
    
    {
    
    label: 'Last Name',
    
    fieldName: 'LastName'
    
    },
    
    {
    
    label: 'Email',
    
    fieldName: 'Email'
    
    },
    
    {
    
    label: 'Phone',
    
    fieldName: 'Phone'
    
    },
    {
    
        label: 'Edit',                        
        
        type: 'button',
        
        initialWidth: 75,
        
        typeAttributes: {
        
        // <!--iconName: 'action:preview',-->
        label: 'Edit', 
        title: 'Edit',
        
        variant: 'border-filled',
        
        alternativeText: 'Edit'
        
        }
        
        
        },
    
    ];
    
    
export default class DisplayAccounts extends LightningElement {

    @track columns = columns;

@track contactRow={};
@track rowOffset = 0;
@track modalContainer = false;
@wire(getDataFromContact) wireContact;
handleRowAction(event) {
const dataRow = event.detail.row;
window.console.log('dataRow@@ ' + dataRow);
this.contactRow=dataRow;
window.console.log('contactRow## ' + dataRow);
this.modalContainer=true;

}

closeModalAction(){

this.modalContainer=true;
}
}