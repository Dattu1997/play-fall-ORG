import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountAccordion extends LightningElement {
    @track activeSections = [];
 
    fields_per_section = [
        {
            label: "Personal data",
            fields: [
                "Name",
                "Phone",
                "Type",
                "Industry",
                "Fax",
                "Description" 
            ]
        },
        {
            label: "Address",
            fields: [
                "BillingAddress",
                "ShippingAddress"
                
            ]
        },
        {
            label: "Contact Info",
            sublabel: "",
            fields: ["Name",
                "AccountName",
                "Phone",
                "Fax"
                
                
            ]
        }
    ];
 
    handleCancel(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
 
    handleSuccess() {
        const event = new ShowToastEvent({
            variant: 'success',
            title: 'Success!',
            message: 'Record has been created',
        });
        this.dispatchEvent(event);
    }
}