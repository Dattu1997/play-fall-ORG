import { api, LightningElement, track, wire } from 'lwc';
import getFieldSet from '@salesforce/apex/CustomDataTableController.getFieldSet';
import getDynamicQuery from '@salesforce/apex/CustomDataTableController.getDynamicQuery';
export default class CustomDataTable extends LightningElement {
@track accountData = [];
@track dynamicData = [];
@track isCheckBoxChecked;
selectedRecord = {};
//checked;
@api objectName ='Account';
@api fieldSetName = 'Account_Field_Set';

connectedCallback(){
    /* getDynamicQuery({objectName : this.objectName,fieldSetName : this.fieldSetName})
    .then(result =>{
        console.log('result---- ',result);
        
        this.dynamicData = result;
        console.log('this.dynamicData ',JSON.parse(JSON.stringify(this.dynamicData)));
     })
    .catch(error =>{
        console.log('error ' ,error);
    }) */
}
@wire(getFieldSet,{objectName : 'Account',fieldSetName : 'Account_Field_Set'})
    wiredData({data,error}){
        if(data){
            console.log('data In label-',data);
                this.accountData = data;
                console.log('this.accountData ',JSON.parse(JSON.stringify(this.accountData)));
                this.error = undefined;
        }
        else if(error){
            console.log('error in label ',error);
            this.error = error;
            this.accountData = undefined;
        }
    }

    handleAllCheckboxes(event){
        //console.log('handleAllCheckBoxes: ',event.target.checked);
        this.isCheckBoxChecked = event.target.checked;
        //console.log('this.checked--',this.isCheckBoxChecked);
    }
    getselectedRow(event){
         this.selectedRecord = JSON.parse(JSON.stringify(event.detail));
        console.log('selectedRecord ', this.selectedRecord);
    }
}