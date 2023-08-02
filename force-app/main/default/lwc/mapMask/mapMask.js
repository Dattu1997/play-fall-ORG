import { LightningElement,api,track } from 'lwc';
import intlTellinputjs from '@salesforce/resourceUrl/intlTellinputjs';
import utils from '@salesforce/resourceUrl/utils';
import intlTellinputcss from '@salesforce/resourceUrl/intlTellinputcss';
import democss from '@salesforce/resourceUrl/democss';
import flags from '@salesforce/resourceUrl/flags';
import { loadScript,loadStyle} from  'lightning/platformResourceLoader';
export default class MapMask extends LightningElement {
    @api CountryName = '';
    @track inputElem ;
    @track iti ;
    connectedCallback() {
        loadStyle(this, democss)
         .then(() => {
              
        });
        loadStyle(this, intlTellinputcss)
         .then(() => {
            
        });
        loadScript(this, utils)
         .then(() => {
            
        });
         loadScript(this, intlTellinputjs)
         .then(() => {
            this.inputElem = this.template.querySelector("[data-id=country]")
            window.intlTelInput(this.inputElem, {
            utilsScript: utils,
            initialCountry: "IN",
            preferredCountries: ['IN','US'],
            })  
        })
    }
}