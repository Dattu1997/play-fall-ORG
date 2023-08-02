import { LightningElement } from 'lwc';
import Companylogo from '@salesforce/resourceUrl/Companylogo';
import PhoneImage from '@salesforce/resourceUrl/PhoneImage'
import searchimage from '@salesforce/resourceUrl/searchimage'
export default class SreachBar extends LightningElement {
    Companylogo = Companylogo;
    phoneimage = PhoneImage ;
    search = searchimage;
    
}