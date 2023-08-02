import { LightningElement } from 'lwc';
import PhoneImage from '@salesforce/resourceUrl/PhoneImage';
import Companylogo from '@salesforce/resourceUrl/Companylogo';
import searchimage from '@salesforce/resourceUrl/searchimage';
export default class CustomCarousel extends LightningElement {
    PhoneImageLogo = PhoneImage;
    Company = Companylogo;
    searchimageLogo = searchimage;
}