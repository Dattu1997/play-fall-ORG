import { LightningElement,track } from 'lwc';
import getListinglocation from '@salesforce/apex/listLocationApex.getListinglocation';
export default class ListLocation extends LightningElement {
    @track display = [];
    search='';
    searchKeyword(event) 
    {
        if(event.target.name == 'search')
        {

        this.search = event.target.value;
        }
    }
    handleSearchKeyword()
    {
        
        getListinglocation({ searchKey:this.search})
        .then(result => {
            result.forEach(dattu => {
                this.display.push({
                    Id : dattu.Id,
                   Name : dattu.Name,
                   State : dattu.State2__c,
                   Category: dattu.Category__c,
                   //Duration: dattu.Duration__c,
                   Price : dattu.Price__c
                })
                console.log(JSON.stringify(this.display));
            })
        })
        
    }
    updateListingHandler(event){
        
    }
}