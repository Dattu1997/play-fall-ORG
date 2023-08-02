import { LightningElement,  api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import Case from '@salesforce/schema/case';
//import CASE_ORIGIN from '@salesforce/schema/Case.Origin';
//import CASE_AccountId from '@salesforce/schema/Case.AccountId';
// import CASE_AssetId from '@salesforce/schema/Case.AssetId';
//import CASE_ContactPhone from '@salesforce/schema/Case.ContactPhone';
//import CASE_contactId from '@salesforce/schema/Case.ContactId';
import CASE_Name from '@salesforce/schema/Account.Name';
import CASE_Description from '@salesforce/schema/Account.Description';
import CASE_Annual from '@salesforce/schema/Account.AnnualRevenue';
import CASE_Fax from '@salesforce/schema/Account.Fax';
import CASE_Industry from '@salesforce/schema/Account.Industry';
export default class CaseRecordForm extends LightningElement {

    @api objectApiName = 'Account';
    @api recordId;
    Fields = [CASE_Name, CASE_Fax, CASE_Description, CASE_Annual, /* CASE_AssetId */, CASE_Industry];

    handlesuccess(event){
        const toastEvent = new ShowToastEvent({
            title :"Case has been created Successfully",
            message: "Case created : ",
            variant : "Success"
        });
        this.dispatchEvent(toastEvent);
    }
}