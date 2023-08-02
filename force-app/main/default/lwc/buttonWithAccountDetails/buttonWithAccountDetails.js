import { LightningElement, track, wire } from 'lwc';
import WrapperAccount from '@salesforce/apex/WrapperClass.WrapperAccount';
export default class ButtonWithAccountDetails extends LightningElement {
    @track acc;
    opp;
    ld;
    @wire(WrapperAccount) getData({data, error}){
        if(data){
            this.acc = data.acc1;
            this.opp = data.opp1;
            this.ld = data.ld1;
            console.log('account',this.acc);

        }
    }
}