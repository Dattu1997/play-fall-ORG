/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */

import lookUpData from '@salesforce/apex/lwcSobjectLookupController.lookUp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';

let FIELDS = ['Owner.Id'];

export default class lwcLookUp extends LightningElement {

    /* List builder */
    @api placeholder = 'Search...';
    @api variant = 'label-hidden';
    @api isTypeListBuilder = false;
    @api isShowPill = false;
    @api isRemovePill = false;
    @api fieldsToDisp =[];
    @api whereClause ='';
    @api dropdownClass = 'slds-dropdown slds-dropdown_length-with-icon-7 slds-dropdown_fluid';
    @api externalData = [];
    @api iconChange = [];
    showSpinner = false;

    @api valueId;
    @api objectApiName;
    @api objName;
	@api objNameField;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api filter = '';
    @api showLabel = false;
    @api uniqueKey;
    @api processRecordId;
    @api isFromFilterScreen = false;
    @api isReadOnly = false;
    @track isComponentLoaded = false;
    @api callingFromGridEditUtility = false;
    @api respectSRules = false;
    @api isUseSOSL = false;
    @api orderBy = '';
    @api recordLimit = 50;
    @api fieldsToShow = FIELDS;
    
    objLabelName;

    /*Create Record Start*/
    @api createRecord = false;
    @track recordTypeOptions;
    @track createRecordOpen;
    @track recordTypeSelector;
    @track mainRecord;
    @track isLoaded = false;
    @track isTypeCase = false;
    @api isDisabled = false;
    //stencil
    @track cols = [1,2];
    @track opacs = ['opacity: 1', 'opacity: 0.9', 'opacity: 0.8', 'opacity: 0.7', 'opacity: 0.6', 'opacity: 0.5', 'opacity: 0.4', 'opacity: 0.3', 'opacity: 0.2', 'opacity: 0.1'];
    @track double = true;

    //For Stencil
    @track stencilClass = '';
    @track stencilReplacement = 'slds-hide';  
    //css
    @track myPadding = 'slds-modal__content';
    /*Create Record End*/

    @track isShow = false;
    searchTerm;
    
	@api valueObj;
    href;
    @track options; //lookup values
    @track isValue;
    @track blurTimeout;

    blurTimeout;

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    connectedCallback() {
        if(this.callingFromGridEditUtility){
            this.createRecord = false;
            if(!this.recordLimit){
                this.recordLimit = '';
            }

            if(!this.orderBy){
                this.orderBy = '';
            }
        }

        this.isComponentLoaded = false;
        if( this.valueId != undefined ){
			this.isValue = true;
			
            if(this.isFromFilterScreen || this.callingFromGridEditUtility){
                 this.valueObj = this.valueId;
            }
			
        }else{
            // if(this.callingFromGridEditUtility){
            //     this.valueObj = this.valueId;
            // }
        }

        this.isTypeCase = (this.objName == 'Case');
    }

    

    renderedCallback() {
        this.isComponentLoaded = true;
        if(this.objName) {
            let temp = this.objName;
            if(temp.includes('__c')){
                let newObjName = temp.replace(/__c/g,"");
                if(newObjName.includes('_')) {
                    let vNewObjName = newObjName.replace(/_/g," ");
                    this.objLabelName = vNewObjName;
                }else {
                    this.objLabelName = newObjName;
                }
                
            }else {
                this.objLabelName = this.objName;
            }
        }
        if(this.callingFromGridEditUtility){
            FIELDS = [this.objName + '.' + this.objNameField];
        }
        this.isShow = true;
    }

    //Used for creating Record Start
    @wire(getObjectInfo, { objectApiName: '$objName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;

            let recordTypeInfos = Object.entries(this.record.recordTypeInfos);
            
            if (recordTypeInfos.length > 1) {
                let temp = [];
                recordTypeInfos.forEach(([key, value]) => {
                    
                    if (value.available === true && value.master !== true) {
                        
                        temp.push({"label" : value.name, "value" : value.recordTypeId});
                    }
                });
                this.recordTypeOptions = temp;
            
            } else {
                this.recordTypeId = this.record.defaultRecordTypeId;
            }

        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("--err1this.error", this.error);
        }
    }
    //Used for creating Record End
    records = [];
    @wire(lookUpData, {searchTerm : '$searchTerm', objectName : '$objName', filter : '$filter',
                        callingFromGridEditUtility : '$callingFromGridEditUtility', 
                        respectSRules : '$respectSRules', isUseSOSL : '$isUseSOSL', orderBy : '$orderBy', 
                        recordLimit : '$recordLimit', isTypeListBuilder : '$isTypeListBuilder', fieldsToDisplay : '$fieldsToDisp', whereClause : '$whereClause'})    //IG-1138 (added param 'isTypeListBuilder' & 'whereClause')
    wiredRecords({ error, data }) {
        if (data) {
            this.showSpinner = true;
            try {
                this.record = data;
                let record = JSON.parse(JSON.stringify(data));
                console.log('lookUp data: ', record.length);
                let noValues = record.length === 0 ? true : false;
                this.error = undefined;
                if(this.isTypeListBuilder){                  
                    let fields = [...this.fieldsToDisp];
                    if(fields.includes('Name') && fields.indexOf('Name') > -1)
                        fields.splice(fields.indexOf('Name'), 1);
                    
                    record.forEach(ele =>{
                        if(this.externalData.includes(ele.Id)){
                            ele.iconName = 'standard:task2';
                        }
                        if(this.iconChange.includes(ele.Id)){
                            ele.iconName = 'standard:task2';
                        }    
                        else
                            ele.iconName = 'standard:account';
                        
                        ele.field = '';
                        for(let i = 0 ; i < fields.length; i++){
                            ele.field += ele[fields[i]] + ' • '
                        }
                    })
                    this.records = record;
                    this.options = record;
                }else{
                    this.options = this.record;
                }
                this.isShow = false;
                setTimeout(() => {
                    this.showSpinner = false; 
                }, 1000);          
                const lookUpData = new CustomEvent('keysearch', {
                    detail: { noValues },
                });
                this.dispatchEvent(lookUpData);
            } catch (error) {
                console.log(error);
            }
            
        } else if (error) {
            this.error = error;
            this.record = undefined;
            this.showSpinner = false;
            console.log("--err2wire.error",this.error);
        }
    }

    //To get preselected or selected record
    @wire(getRecord, { recordId: '$valueId', fields: '$fieldsToShow' })
    wiredOptions({ error, data }) {
        if (data) {
            this.record = data;            
            this.error = undefined;
            this.isComponentLoaded = false;

            if(this.objName == 'Case'){
                this.valueObj = this.record.fields.CaseNumber.value;
            }else{
                this.valueObj = this.record.fields.Name.value;
            }
            //this.valueObj = this.record.fields.Name.value;
			// this.valueObj = this.record.fields[this.objNameField].value;
            this.href = '/'+this.record.id;
            this.isValue = true;
            
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("--err3FIELDS", FIELDS);
            console.log("--err3this.error", this.error);
        }
    }

    //when valueId changes
    valueChange() {
    }

    handleClick() {
        if(!this.isDisabled){
            this.searchTerm = '';
            this.inputClass = 'slds-has-focus';
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
            //let combobox = this.template.querySelector('#box');
            //combobox.classList.add("slds-is-open"); 
            if(this.isTypeListBuilder && this.searchTerm == ''){
                this.records.forEach(rec =>{
                    if(this.externalData.includes(rec.Id)){
                        rec.iconName = 'standard:task2';
                    }else{
                        rec.iconName = 'standard:account';
                    }
                })
                this.options = this.records;
            }
        }
    }

    inblur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let ele = event.currentTarget;
        let selectedId = ele.dataset.id;
		let selectedName = ele.dataset.name;
        //As a best practise sending selected value to parent and inreturn parent sends the value to @api valueId
        let key = this.uniqueKey;
		this.valueObj = selectedName;
        this.href = '/'+ selectedId;
        this.isValue = false;
        if(this.isShowPill){
            this.isValue = false;
        }else{
            this.isValue = true;
        }
        let recordId = this.processRecordId;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key, selectedName, recordId},
        });
        this.dispatchEvent(valueSelectedEvent);

        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    handleRemovePill() {
        if(this.isRemovePill){
            //do nothing...
            console.log('in romove pill--');
        }else{
            console.log('in else remove--');
            this.isValue = false;
            //this.isDisabled = true;
            let selectedId = '';
            let key = this.uniqueKey;
            let recordId = this.processRecordId;
            const valueSelectedEvent = new CustomEvent('valueselect', {
                detail: { selectedId, key, recordId },
            });
            this.dispatchEvent(valueSelectedEvent);   
        }
    }

    createRecordFunc() {
        if (this.recordTypeOptions) {
            this.recordTypeSelector = true;
        }else {
            this.recordTypeSelector = false;
            this.mainRecord = true;
            //stencil before getting data
            this.stencilClass = '';
            this.stencilReplacement = 'slds-hide';
        }
        this.createRecordOpen = true;
    }

    handleRecTypeChange(event) {
        this.recordTypeId = event.target.value;
    }

    createRecordMain() {
        this.recordTypeSelector = false;
        this.mainRecord = true;
        //stencil before getting data
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
    }

    handleLoad(event) {
        let details = event.detail;

        if(details) {
            setTimeout(() => {
                this.stencilClass = 'slds-hide';
                this.stencilReplacement = '';
                this.myPadding = 'slds-p-around_medium slds-modal__content';
            }, 1000);
        }

    }

    handleSubmit() {
        this.template.querySelector('lightning-record-form').submit();
    }

    handleSuccess(event) {
 
        this.createRecordOpen = false;
        this.mainRecord = false;
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';

        let selectedId = event.detail.id;
        let key = this.uniqueKey;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key },
        });
        this.dispatchEvent(valueSelectedEvent);

        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Success',
                message : `Record saved successfully with id: ${event.detail.id}`,
                variant : 'success',
            }),
        )
    }

    handleError() {

        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : 'Error saving the record',
                variant : 'error',
            }),
        )
    }

    closeModal() {
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
        this.createRecordOpen = false;
        this.recordTypeSelector = false;
        this.mainRecord = false;
    }

    /**
     * @description : For listBuilder.lwc
     * @AddedDate : 07-12-2022
    */
    @api
    clearSelection(){
        console.log('in clearSelection');
        this.isValue = false;
        // this.handleRemovePill();
    }

    /**
     * @description : To set search bar focus to active (set a timeout if DOM is not loaded while calling this func)
     * @info : https://app.clickup.com/t/8406164/IG-1212
    */
    @api
    setInputFocus(){
        let inputSearch = this.template.querySelector("lightning-input");
        inputSearch.focus();
        this.handleClick()
    }
}