import { LightningElement,api,track } from 'lwc';
export default class ChildComponent extends LightningElement {
    @api fields
    @api fieldApi
    @api fieldType
    @api fieldLabel
    @api isEdit
    @track Name;
    @track Email;
    Phone= 623415837;

    connectedCallback(){
        console.log('connected '+this.fields+'field api'+fieldApi);
    }

    get isText(){
        return this.fieldType ==='Text';
        
    }
    get isEmail(){
        System.debug('the email');
        return this.fieldType ==='Email';
        
    }
    get isPhone(){
        return this.fieldType ==='Phone';
    }
    

    getDetails(event){
        console.log('edit button is calling');
        console.log(event.target.label);
        console.log(event.target.value);
        if(event.target.label=='Name')
        {
       this.Name=event.target.value;
        }
       console.log(this.Name);
       if(event.target.label=='Email')
       {
       this.Email=event.target.value;
       console.log(this.Email);
       }

       const selectedEvent = new CustomEvent("testchange",{
           detail:{
               Name:this.Name,
               Email:this.Email
           }
       });
       this.dispatchEvent (selectedEvent);


    }
    

    }