import { LightningElement, api,wire, track } from 'lwc';
import fetchLookupData from '@salesforce/apex/LookUpLwcController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/LookUpLwcController.fetchDefaultRecord';
const DELAY = 300;
export default class CustomLookupLwc extends LightningElement {
    @api placeholder; 
    @api iconName;
    @api sObjectApiName;
    @api defaultRecordId = '';
    @api disableInput = false;
    @api dropDown ="slds-dropdown slds-dropdown_length-with-icon-7 slds-dropdown_fluid";
    toggleLookup = false;
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    @api searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    //@api autofocus;
    selectedRecord = {}; // to store selected lookup record in object formate 
   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
        console.log('In connectdCallBack---');
        if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    console.log('this.selectedRecord ',this.selectedRecord);
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                    //this.checkBoxChecked();
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
        }
        
    }
    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName' })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
            this.hasRecords = data.length == 0 ? false : true; 
            this.lstResult = JSON.parse(JSON.stringify(data));
        }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        console.log('In HandleChange-------');
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }
    // method to toggle lookup result section on UI 
    toggleResult(event){
        //console.log('In toggle======',event);
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        //console.log('lookupInputContainer ',lookupInputContainer);
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        //console.log('whichEvent 74--',whichEvent);
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');                
               break;
            
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                   
        }
        // const inputVal = this.template.querySelector('lightning-input');
        // console.log('inputVal======== ',JSON.stringify(inputVal) );
        
    }
    // method to clear selected lookup record  
    handleRemove(){
        console.log('In remove=====');
        this.searchKey = '';    
        this.selectedRecord = {};
        this.remove = true;
        console.log('In chlidh remove value--', this.remove);
        this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        //console.log('searchBoxWrapper ',JSON.parse(JSON.stringify(searchBoxWrapper)));
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        //console.log('pillDiv ',JSON.parse(JSON.stringify(this.pillDiv)));
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
        
    }
    // method to update selected record from search result 
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        console.log('obj--',objId);
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
        console.log('selectedRecord: ', this.selectedRecord);
        this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI

    }
    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        // console.log('In handle helper--',this.template.querySelector('.lookupInputContainer').classList);
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        // console.log('searchBoxWrapper ',JSON.parse(JSON.stringify(searchBoxWrapper)));
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector ('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
    }
    @api checkBoxChecked(){        
        console.log('In checkBoxChecked-------');
        this.template.querySelector('.slds-dropdown_fluid').classList.remove('slds-show');
        // console.log('classList In remove',this.template.querySelector('.slds-dropdown_fluid').classList);
        this.template.querySelector('.slds-dropdown_fluid').classList.add('slds-hide');
        // console.log('classList in addd Method ',this.template.querySelector('.slds-dropdown_fluid').classList);
    }
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value){    
        const oEvent = new CustomEvent('lookupupdate',
        {
            'detail': {selectedRecord: value}
        }
    );
    this.dispatchEvent(oEvent);
    }

    @api setFocusOnLookUp(){
        setTimeout(() => {
        const firstInput = this.template.querySelector('lightning-input');
        if (firstInput) firstInput.focus();
        }, "1000");
    }

    handleBlur(){
        // console.log('in blur');
        // const handleBlur = this.template.querySelector('[id=id5-121]');
        // handleBlur.classList.add('slds-hide');
        // handleBlur.classList.remove('slds-show');
        
        // console.log('In child blur event---', handleBlur);
        
        const showLookUp = this.template.querySelector('[id=id5-121]');
        showLookUp.classList.add('slds-show');
        showLookUp.classList.remove('slds-hide');
        console.log('lookup---',showLookUp);
        
    }
    
}