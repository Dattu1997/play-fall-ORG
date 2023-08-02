import { LightningElement, track } from 'lwc';
import WrapperAccount from '@salesforce/apex/WrapperClass.WrapperAccount';
export default class AccountTabs extends LightningElement {
    
      accId ={};
      accountData ={};
      oppData ={};
      ldData ={};
    connectedCallback(){
    WrapperAccount ({data : this.accId})
     .then((result)=>{
            console.log('result'+result);
            this.accountData = result.acc1;
            this.oppData = result.opp1;
            this.ldData = result.ld1; 
            console.log('accountData',this.accountData);
            console.log('oppData',this.oppData);
            console.log('ldData',this.ldData);
                })
        .catch((error)=>{
            this.error = error;
            this.accountData = undefined;
        })
    
        
    }
    
    
}