import { LightningElement,track } from 'lwc';
import fetchAccount from '@salesforce/apex/relatedContacts.fetchAccount';
import fetchContact from '@salesforce/apex/relatedContacts.getContacts';


const columns = [{
    label: 'First Name',
    fieldName: 'FirstName'
},
{
    label: 'Last Name',
    fieldName: 'LastName'
},
{
    label: 'Email',
    fieldName: 'Email',
    type: 'email'
},
{
    label: 'Phone',
    fieldName: 'phone',
    type: 'phone'
}

];

// const columnsOpp = [{
//     label: 'Name',
//     fieldName: 'Name'

// }

// ];
export default class AccountRelatedContact extends LightningElement {

    @track acc;
@track con;
message;
msg;
@track opp;
connectedCallback(){
fetchAccount()
.then(result => {
this.acc = result;

console.log(JSON.stringify(result));
console.log("result",this.acc);
})

}


contactFetch(event){
this.message = event.target.value;
console.log('Contact Id-->'+this.message);
fetchContact({accountId : this.message})

.then(result => {
this.con = result;

console.log(JSON.stringify(result));
console.log("result1",this.con);
})
.catch(error =>{
this.error = error;

})

// this.msg = event.target.value;
// console.log('Oppoertunity Id-->'+this.msg);
// fetchOpportunity({accountId : this.msg})
// .then(result => {
// this.opp = result;

// console.log(JSON.stringify(result));
// console.log("result2",this.opp);
// })
// .catch(error =>{
// this.error = error;

// })
}
}