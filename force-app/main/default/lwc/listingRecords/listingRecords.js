import { LightningElement, track} from 'lwc';
import getCategoryPickList from '@salesforce/apex/listingRecordsApex.getCategoryPickList';
import getStatusPickList from '@salesforce/apex/listingRecordsApex.getStatusPickList';
import getStatePickList from '@salesforce/apex/listingRecordsApex.getStatePickList';
import getDurationPickList from '@salesforce/apex/listingRecordsApex.getDurationPickList';
import savelistingRecords from '@salesforce/apex/listingRecordsApex.savelistingRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const MAX_FILE_SIZE = 100000000;//10MB
export default class ListingRecords extends LightningElement
{
    ListingName;
    Category;
    Duration;
    Street;
    City;
    State;
    PostalCode;
    Country;
    Status;
    BasePrice;
    NoOfDays;
    PricePerPerson;
    GuestMinCapacity;
    GuestMaxCapacity;
    ItemsToBring;
    PickUpLocation;
    Description;
    WhatsInclude;
    OtherConsiderations;
    @track categoryPL;
    @track statusPL;
    @track statePL;
    @track durationPL;
    connectedCallback() {
        getCategoryPickList()   
            .then(result => {
                let opt = [];
                result.forEach(element => {
                    opt.push({
                        label : element,
                        value : element
                    })
                   });
                this.categoryPL = opt;
            })
        getStatusPickList()
            .then(result => {
                let opt = [];
                result.forEach(element => {
                    opt.push({
                        label : element,
                        value : element
                    })
                });
                this.statusPL = opt;
            })
        getStatePickList()
            .then(result => {
                let opt = [];
                result.forEach(element => {
                    opt.push({
                        label : element,
                        value : element
                    })
                });
                this.statePL = opt;
            })
        getDurationPickList()
            .then(result => {
                let opt = [];
                result.forEach(element => {
                    opt.push({
                        label : element,
                        value : element
                    })
                });
                this.durationPL = opt;
            })
    }
    handleChange(event)
    {
        if(event.target.label == 'Listing Name')
        {
            this.ListingName = event.target.value;
            console.log('ListingName----> : '+this.ListingName);
        }
        if(event.target.label == 'Category')
        {
            this.Category = event.target.value;
        }
        if(event.target.label == 'Duration')
        {
            this.Duration = event.target.value;
        }
        if(event.target.label == 'Street')
        {
            this.Street = event.target.value;
        }
        if(event.target.label == 'City')
        {
            this.City = event.target.value;
        }
        if(event.target.label == 'State')
        {
            this.State = event.target.value;
        }
        if(event.target.label == 'Zip/Postal Code')
        {
            this.PostalCode = event.target.value;
        }
        if(event.target.label == 'Country')
        {
            this.Country = event.target.value;
        }
        if(event.target.label == 'Status')
        {
            this.Status = event.target.value;
            console.log('Status----> : '+this.Status);
        }
        
        if(event.target.label == 'Base Price')
        {
            this.BasePrice = event.target.value;
            console.log('BasePrice----> : '+this.BasePrice);
        }
        
        if(event.target.label == 'Number of Days')
        {
            this.NoOfDays = event.target.value;
            console.log('Number Of days----> : '+this.NoOfDays);
        }
        
        if(event.target.label == 'Price Per Person')
        {
            this.PricePerPerson = event.target.value;
        }
        if(event.target.label == 'Guest Min Capacity')
        {
            this.GuestMinCapacity = event.target.value;
        }
        if(event.target.label == 'Guest Max Capacity')
        {
            this.GuestMaxCapacity = event.target.value;
        }
        if(event.target.label == 'Items to Bring')
        {
            this.ItemsToBring = event.target.value;
            console.log('Items to bring----> : '+this.ItemsToBring);
        }
        if(event.target.label == 'Pick Up Location')
        {
            this.PickUpLocation = event.target.value;
        }
         if(event.target.label == 'Description')
        {
            this.Description = event.target.value;
            console.log('Description----> : '+this.Description);
        }
        if(event.target.label == 'Whats Include')
        {
            this.WhatsInclude = event.target.value;
            console.log('wat'+this.WhatsInclude);
        }
        if(event.target.label == 'Other Considerations')
        {
            this.OtherConsiderations = event.target.value;
            console.log('other'+this.OtherConsiderations);
        }
    }
    submitDetails()
    
    {
     
        console.log('inside save')
        var listingRecord = {};
        listingRecord.Name = this.ListingName;
        listingRecord.Category__c = this.Category;
        listingRecord.Duration__c = this.Duration;
        listingRecord.Street__c = this.Street;
        listingRecord.City__c = this.City;
        listingRecord.State2__c = this.State;
        console.log(sdsdfdg+'this.State');
        listingRecord.Zip_Postal_Code__c = this.PostalCode;
        listingRecord.Country__c = this.Country;
        listingRecord.Status__c = this.Status;
        listingRecord.Price__c = this.BasePrice;
        listingRecord.Number_Of_Days__c=this.NoOfDays;
        listingRecord.Additional_Price_per_Person__c = this.PricePerPerson;
        listingRecord.Guest_Min_Capacity__c = this.GuestMinCapacity;
        listingRecord.Guest_Max_Capacity__c = this.GuestMaxCapacity;
        listingRecord.Items_To_Bring__c = this.ItemsToBring;
        listingRecord.Pick_Up_Location__c = this.PickUpLocation;
        listingRecord.Description__c = this.Description;
        listingRecord.What_s_Included__c = this.WhatsInclude;
        listingRecord.Other_Considerations__c = this.OtherConsiderations;
       
        this.fileReader = new FileReader();  
        this.fileReader.onloadend = (() => {  
          this.fileContents = this.fileReader.result;  
          let base64 = 'base64,';  
          this.content = this.fileContents.indexOf(base64) + base64.length;  
          this.fileContents = this.fileContents.substring(this.content);  
          savelistingRecords();  
        }); 
        const isInputCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar,inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        },true);
        if(isInputCorrect)
        { 
        this.fileReader.readAsDataURL(this.file);  
        savelistingRecords({listingDetails : listingRecord,
            file: encodeURIComponent(this.fileContents),  
            fileName: this.fileName});
                [...this.template
            .querySelectorAll('lightning-input,lightning-combobox, lightning-input-rich-text')]
            .forEach((input) => { input.value = ''; });
   }
}
   resetPage() {
    [...this.template
        .querySelectorAll('lightning-input,lightning-combobox, lightning-input-rich-text')]
        .forEach((input) => { input.value = ''; });

}
openfileUpload(event) { 
    if (event.target.files.length > 0) { 
     this.uploadedFiles = event.target.files; 
     this.fileName = event.target.files[0].name; 
     this.file = this.uploadedFiles[0]; 
     if (this.file.size > this.MAX_FILE_SIZE) { 
      alert("File Size Can not exceed" + MAX_FILE_SIZE); 
     } 
    } 
   }
}