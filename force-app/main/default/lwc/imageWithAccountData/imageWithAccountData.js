import { LightningElement, wire, api } from 'lwc';
import imageAccount from '@salesforce/apex/imageWithAccount.imageAccount';
export default class ImageWithAccountData extends LightningElement {
     
               
        
    accId = {};
    accountData={};
     connectedCallback(){
    imageAccount ({data : this.accId})
    .then((result)=>{
        console.log('result'+result);
        this.accountData = result;
        console.log('accountdetails',this.accountData);
    })
    

    
       
     
}
}