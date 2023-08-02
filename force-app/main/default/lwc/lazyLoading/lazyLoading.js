import { LightningElement } from 'lwc';
import getAccountData from '@salesforce/apex/LwcLoadingController.getAccountData';
const columns = [
    {
        label: 'Account Name', fieldName: 'linkAccount', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date',
            typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        } 
    }
 ];
export default class LazyLoading extends LightningElement {
    columns = columns;
    data = [];
    items = [];
    error;
    totalNumberOfRows = 10; // stop the infinite load after this threshold count
    recordCount = 10;
    loadMoreStatus;
    totalRecountCount = 0;
    targetDatatable;
    connectedCallback() {
        this.getData();
    }
    getData(){
        getAccountData({})
        .then(result => {
            result = JSON.parse(JSON.stringify(result));
            result.forEach(record => {
                record.linkAccount = '/' + record.Id;
            });
            this.totalRecountCount = result.length;
            console.log('this.totalRecountCount ',this.totalRecountCount);
            this.items = [...this.items, ...result];
            console.log('this.items--',this.items);
            this.data = this.items.slice(0, this.recordCount); 
            console.log('this.data- ',this.data);
            this.error = undefined;
        }).catch(error => {
            this.error = error;
            this.data = undefined;
            this.items = undefined;
        });
    }
    getRecords() {
        this.recordCount = (this.recordCount > this.totalRecountCount) ? this.totalRecountCount : this.recordCount; 
        //console.log('this.recordCount--- ',this.recordCount);
        this.data = this.items.slice(0, this.recordCount);
        this.loadMoreStatus = '';
        if (this.targetDatatable){
            this.targetDatatable.isLoading = false;
        }
    }
    // Event to handle onloadmore on lightning datatable markup
    handleLoadMore(event) {
        console.log('in event--');
        event.preventDefault();
        // increase the record Count by 20 on every loadmore event
        this.recordCount = this.recordCount + 20;
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