import { api, LightningElement } from 'lwc';

export default class CustomSpinner extends LightningElement {
     @api isLoading = false;
     //showButon = true

    // showSpinner() {
    // if (!this.isLoading) {
    //     this.isLoading = true;
    //         this.showButon =false;
    //   } else {
    //     this.isLoading = false;
    //     this.showButon = false;
    //   }
    // }
}