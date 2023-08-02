import { LightningElement, track, api } from 'lwc';
import getAccount from '@salesforce/apex/ContactController.getAccountContacts';
import getContactsSaved from '@salesforce/apex/ContactController.getContactsSaved';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
const columns = [
    {label: 'FirstName', fieldName: 'FirstName', type: 'text',editable: true,sortable: "true"},
    {label: 'LastName', fieldName: 'LastName', type: 'text',editable: true,sortable: "true"},
    {label: 'Phone', fieldName: 'Phone', type: 'Phone',editable: true,sortable: "true"},
    {label: 'Email', fieldName: 'Email', type: 'email',editable: true,sortable: "true"},
];
export default class ContactsData extends LightningElement {
    @api recordId;
    columns = columns;
    data = [];
    draftValues = [];
    contactsData = [];
    isModalOpen = false;
    errorMsg;
    @track totalRecords = 0;
    @track pageSize = 5;
    @track pageNumber = 1;
    @track totalPages;
    @track sortBy;    
    @track sortDirection;
    @track currentPage =1;
    @track disableButton = false;
    @track isPrev = true;
    @track isNext = false;
    
    connectedCallback(){
        console.log('connected callback');
        getAccount({recordId : this.recordId}) 
        .then(result => {
            if(result.length == 0){
                this.disableButton = true
            }
        })
        .catch(error =>{
            console.log('error--- ', error)
            this.errorMsg = error.message;
        })
    }
   
    getData(){
        getAccount({recordId : this.recordId}) 
        .then(result => {
            this.page =result.data;
            this.data = result;
            this.getContacts();
            this.totalRecords = this.data.length;
            this.pageNumber = this.data.pageNumber;
            this.pageSize = Number(this.pageSize);
            this.totalPages = Math.ceil(this.totalRecords/this.pageSize);
        })
        .catch(error =>{
            console.log('ERROR --> ', error);

        })    
    }
    openModal() {
        this.isModalOpen = true;
        this.getData();
    }
    closeModal() {
        this.isModalOpen = false;
    }
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log("chk1" +JSON.stringify(updatedFields));
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
        console.log("chk2" +JSON.stringify(notifyChangeIds));
        await getContactsSaved({con: updatedFields})
        .then(result => {
            console.log(JSON.stringify("Apex update result: "+ result));
            if(result === true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'successfully Contact has been updated',
                        variant: 'success',
                    })
                );

                getRecordNotifyChange(notifyChangeIds);
                       refreshApex(this.data).then(() => {
                         this.draftValues = [];
                        });
            } 
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'something went wrong please try again',
                        variant: 'error'
                    })
                );
            }
        })
       window.location.reload();
    }
    getContacts(){
        const start = (this.currentPage-1)*this.pageSize
        const end = this.pageSize*this.currentPage
        this.isModalOpen = true;
        this.contactsData = this.data.slice(start,end);

    }
    handlePageNextAction(){
        if(this.currentPage < this.totalPages){
            this.currentPage = this.currentPage+1
            this.getContacts()
        } 
        if(this.currentPage < this.totalPages){
            this.isPrev = false;
        }
        if(this.currentPage == this.totalPages){
            this.isNext = true;
            this.isPrev = false;
        }      
    }
   
    handlePagePrevAction(){
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.getContacts()
        } 
        if(this.currentPage > 1){
            this.isNext = false;
        }  
        if(this.currentPage == 1){
            this.isPrev = true;
            this.isNext = false;
        }     
    }
    
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.contactsData));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.contactsData = parseData;
    }
}