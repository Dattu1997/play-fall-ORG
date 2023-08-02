import { LightningElement, wire, api, track } from 'lwc';
import getAccounts from '@salesforce/apex/displayTagDataController.getAccounts';
import getAccountRecord from '@salesforce/apex/displayTagDataController.getAccountRecord';
import getAccountContactUpadate from '@salesforce/apex/LookUpLwcController.getAccountContactUpadate';
import getContactSaved from '@salesforce/apex/ContactModalPopUpController.getContactSaved';
import retrieveContacts from '@salesforce/apex/displayTagDataController.retrieveContacts';
import deleteMultipleContactRecord from '@salesforce/apex/displayTagDataController.deleteMultipleContactRecord';
import getContactUpdate from '@salesforce/apex/displayTagDataController.getContactUpdate';
import Id from '@salesforce/schema/Attachment.Id';

const columns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Description', fieldName: 'Description', type: 'text'},
    {label: 'Industry', fieldName: 'Industry', type: 'text'},
    {label: 'Website', fieldName: 'Website', type: 'url'}
];
const column = [
    {label: 'First Name', fieldName: 'FirstName', type: 'text'},
    {label: 'Last Name', fieldName: 'LastName', type: 'text'},
    {label: 'Email', fieldName: 'Email', type: 'Email'},
    {label: 'Phone', fieldName: 'Phone', type: 'Phone'},
    
];
export default class DisplayTagData extends LightningElement {

    
    @api mode = 'edit';
    isAdd = false;
    isEdit = false;
    topValue = false;
    showBackToTop = false;
    @track disableButton = true;
    @track showTable =false;
    @track showlookUp = false;
    @track disablecheckbox = true;
    @api rowId;
    //data;
    columns = columns;
    columnsValues = column;
    @track accountdata = [];
    rowSelected = [];
    selectedRec = {};
    selectedData = {};
    selectedAccountData = {};
    selectedAccount = {};
    selectedAccountRec =[];
    deleteContacts={};
    checked = [];
    unChecked = [];
    selectedRows = [];
    checkedRow = [];
    topUp = [];
    allChecked = [];
    acc;
    con;
    accObj;
    conObj;
    accntId;
    contId;
    dataIdCheck ={} ;
    previous = {};
    @api recordId;
    accountId = '';
    error;
    isModalOpen = false;
    focusValue = false;
    contactDetails;
    //contactLookUp;
    error;
    @track lastName = '';
    @track emailval = '';
    @track contacts;
    @track data=[];
    @track selectedAcc;
    isSpinner = false;
    selectedContacts;
    //@track valueField = false;
    @track disableSearch = true;
    @track applyButton = true;
    items = [];
    totalNumberOfRows = 50; // stop the infinite load after this threshold count
    recordCount = 20;
    loadMoreStatus;
    totalRecountCount = 0;
    targetDatatable;
    connectedCallback(){
        console.log('in connectedCallback ', 'mode: ', this.mode);
        if(this.mode == 'edit'){
            this.isEdit = true;
            setTimeout(() => {
                this.template.querySelector('c-custom-lookup-lwc').setFocusOnLookUp();
            }, "1000");
        }else if(this.mode === 'Add'){
            this.isAdd = true;
            
        }
        getAccounts()
        .then(result =>{
            if(result){
                this.accountdata = result;
                // console.log('accountData '+JSON.stringify(this.accountdata));
            }
        })
        .catch(error =>{
            this.error = error;
      })
        
    }

    @wire(getAccounts)
    accounts(result) {
        if (result.data) {
            this.data = result.data;
            this.error = undefined;

        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    //lookupContact method is in isAdd mode to get the data from child component in lookUp.
    lookupContact(event){
        console.log('In contact lookup----', JSON.parse(JSON.stringify(event.detail)));
        this.isAdd = true;
        this.isEdit = false;
        let selectedContactData = JSON.parse(JSON.stringify(event.detail));
        console.log('contact Data=='+ selectedContactData);
        this.selectedData = selectedContactData["selectedRecord"]["Id"];
        console.log('this.selectedData--',this.selectedData);
        if(this.selectedData == '' || this.selectedData == null){
            console.log('In else condition---',this.selectedData);
            this.applyButton = true;
            this.disablecheckbox = true;
        }
        else if(this.selectedData !='' || this.selectedData != null){
            this.applyButton = false;
            this.disablecheckbox = false;
        }
        this.con = JSON.stringify(this.selectedData.Id);
        console.log('Apex Contact Data ==='+this.con);
        
    }    
    
    //this method is to get the data in lookUp in isadd mode.
    lookupAccountRecord(event){              
        this.isAdd = true;
        this.isEdit = false;
        let selectedAccountData = JSON.parse(JSON.stringify(event.detail));
        console.log('Account Data======='+ selectedAccountData);
        this.recordId = selectedAccountData["selectedRecord"]["Id"];
        console.log('this.recordId ',this.recordId);
        this.template.querySelector('c-custom-lookup-lwc').checkBoxChecked();
    }

    // to get the accounts data in data table from apex in isAdd mode.
    @wire(getAccountRecord, {recordId: '$recordId'})
    accountData({data,error}){
        if(data){
            console.log('data ',data);
            this.isEdit = false;
            this.isAdd = true;
            var dataToAdd = JSON.parse(JSON.stringify(this.accountdata));
            console.log('dataToAdd ',dataToAdd);
            var newObject ={};
            data.forEach(element =>{
                console.log('element---- ',element);
                newObject.Id = element['Id'];
                newObject.Name = element['Name'];
                newObject.Description = element['Description'];
                newObject.Industry = element['Industry'];
               
            });
            const rows = [newObject.Id];
            console.log('rows ',rows);
            dataToAdd.push(newObject);
            console.log('dataToAdd ',dataToAdd);
            this.accountdata = JSON.parse(JSON.stringify(dataToAdd));
            console.log('this.accountdata 163=== ',this.accountdata);
            this.rowSelected = rows;
            
        }else{
            this.error = error;
            //console.log(JSON.stringify(this.error));
        }
    }

    handleRowAction(event){
        this.selectedRec = event.detail.selectedRows;
        console.log('selectedRec '+JSON.stringify(this.selectedRec));
        this.acc = JSON.stringify(this.selectedRec[0].Id);
        //console.log('Igbtnrdyt'+JSON.stringify(this.selectedRec[0].Id));
    }

    handleClose(){
        window.open();        
    }

    handleClick(){
        getAccountContactUpadate({acc : this.acc, con : this.con})
            .then(e => {
                console.log(e);
                this.dispatchEvent(new CustomEvent(
                    "notification", 
                    {
                        detail: {e}                        
                    }
                ));
            })
    }
    getContactVal(event){
        this.lastName = event.target.value;
    }
    getEmailVal(event){
        this.emailval = event.target.value;
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    
    //handleSave method is in isAdd mode 
    handleSave(){
        this.isSpinner = true;    
        getContactSaved({lastName : this.lastName, email : this.emailval})
        .then(result =>{
            this.closeModal();
            console.log('result----- ',result.LastName);
            this.contactDetails = result;
            console.log('this.contactDetails ',this.contactDetails);
            //this.contactLookUp = result.LastName;
            this.isSpinner = false;
        }).catch(error =>{
            this.error = error;
            this.isSpinner = false;
        })
        this.lastName = '';
        this.emailval= '';
    }
// The Account data is displayed in isEdit Mode.
    handleClickAccount(event){
        console.log('In handle click Account---', JSON.parse(JSON.stringify(event.detail)));
        this.blueEvent = true;
        this.isAdd = false;
        this.isEdit = true;
        this.disableButton = false;
        this.showTable = true;
        this.showlookUp = true;
        var contactData = [];
        let myIds = [];
        let selectedAccount = JSON.parse(JSON.stringify(event.detail));
        console.log('selectedAccount123-- ',selectedAccount);
        this.accountId = selectedAccount['selectedRecord']['Id'];
        if(this.accountId == null || this.accountId == ''){
            console.log('In else if ---- ',this.accountId);
            this.showTable = false;
            this.showlookUp = false;
            this.disableButton = true;
        }
        else if(this.accountId != '' || this.accountId != null){
            this.disableSearch = false;
            retrieveContacts({accId : this.accountId})
            .then(res =>{
                console.log('result In contact data table ',res);
                contactData.push(res);
                console.log('contacts--- ',contactData);
                this.contacts = [...contactData[0]];
                console.log('this.contacts=== ',this.contacts);
                this.contacts.forEach(function (acc, index){
                    myIds.push(acc.Id);
                });
                myIds.push(this.contacts[0].Id);
                this.allChecked = myIds;
                this.totalRecountCount = res.length;
                console.log('this in total--',this.totalRecountCount);
                this.items = [...this.items, ...res];
                this.contacts = this.items.slice(0, this.recordCount);
                
            }).catch(error =>{
                console.log('error : ',error);
            })
            //this.template.querySelector('c-custom-lookup-lwc').handelSelectRecordHelper();
            
        }
        console.log('In other If----');
    }

    //getSelectedRecords to  ckeck the selected the selected row in data table.
    getSelectedRecords(event){
        this.isAdd = false;
        this.isEdit = true;
        const selRows = event.detail.selectedRows;
        console.log( 'Selected Rows are ' + JSON.stringify ( selRows ) );
        if ( this.selectedRows.length < selRows.length ) {
            //console.log('in If --', this.selectedRows);
        } else {
           console.log( 'Deselected' );
           let deselectedRecs = this.selectedRows.filter(x => !selRows.includes(x)).concat(selRows.filter(x => !this.selectedRows.includes(x)));
           console.log( 'Deselected Recs are ', JSON.stringify( deselectedRecs ) );
       }
       this.selectedRows = selRows;
    }

    // allChecked(){
    //     this.isEdit = true;
    //     this.isAdd = false;
    //     this.checkedRow = this.template.querySelector("lightning-datatable[data-id=ldt]").selectedRows;
    //     console.log('in 306---',this.checkedRow);
    // }

    //handleRemove in isEdit mode remove button to remove account related contact from data table. 
    handleRemove(){
        console.log('this.accountId', this.accountId);
        var selectedContacts = [];
        this.template.querySelector("lightning-datatable[data-id=ldt]").getSelectedRows().forEach(ele =>{
            console.log('ele',ele);
            selectedContacts.push(ele);
        })
        this.selectedContacts = JSON.stringify(selectedContacts);
        console.log('selectedContacts ', this.selectedContacts);
        deleteMultipleContactRecord({conObj : this.selectedContacts, accId : this.accountId})
        .then(result =>{
            console.log('result12-- ',result);
            var contacts = result;
            this.contacts = [...contacts];

        }).catch(error =>{
            console.log('error ',error);
        })
        
    }

    //lookupContactRecord lookup from child component in isEdit mode to add the contacts in data table.
    lookupContactRecord(event){
        console.log('In contact LookUp---');
        this.isEdit = true;
        this.topValue = true;
        this.isAdd = false;
        let selectedContactData = JSON.parse(JSON.stringify(event.detail));
        console.log('Contact Data=======', selectedContactData);    
        this.recordId = selectedContactData['selectedRecord']['Id'];
        console.log('this.recordId ',this.recordId);
        getContactUpdate({contId : this.recordId, accntId : this.accountId})
        .then(result =>{
            console.log('result In contact update ',result);
            var contacts = result;
            this.contacts = [...contacts];
            console.log('In checkbox remove--');
            this.template.querySelector('c-custom-lookup-lwc').checkBoxChecked();
            
        }).catch(error =>{
            console.log('error ',error);
        })
    }

    renderedCallback(){
        console.log('in renderCallBck 309---');
        this.isEdit = true;
        this.isAdd = false;
        if(this.topValue){
                let topUp = document.getElementsByTagName('table');
                    topUp.scrollTop = 0;
                    this.topValue= false;
        }
        
    }   

    getRecords() {
        console.log('in ttgui---');
        this.recordCount = (this.recordCount > this.totalRecountCount) ? this.totalRecountCount : this.recordCount; 
        this.contacts = this.items.slice(0, this.recordCount);
        //console.log('360---',JSON.stringify(this.contacts));
        this.loadMoreStatus = '';
        if (this.targetDatatable){
            this.targetDatatable.isLoading = false;
        }
    }

    handleLoadMore(event) {
        console.log('in onLoad---');
        event.preventDefault();
        // increase the record Count by 20 on every loadmore event
        this.recordCount = this.recordCount + 10;
        console.log('this recordCount 371--',this.recordCount);
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Set the onloadmore event taraget to make it visible to imperative call response to apex.
        this.targetDatatable = event.target;
        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';
        // Get new set of records and append to this.data
        this.getRecords();
    }
    
}