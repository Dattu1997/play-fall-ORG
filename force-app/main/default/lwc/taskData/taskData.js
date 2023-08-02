import { LightningElement, track, wire } from 'lwc';
//import getTaskData from '@salesforce/apex/TaskController.getTaskData';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status_FIELD from '@salesforce/schema/Task.Status';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import TASK_OBJECT from '@salesforce/schema/Task';

export default class TaskData extends LightningElement {
    @track customFormModal = false; 
    @track startDt;
    @track startDtToFirstOfMonth;


    customShowModalPopup() {            
        this.customFormModal = true;
    }
 
    customHideModalPopup() {    
        
        this.customFormModal = false;
    }
    
    handleStDateCahngeEvent(event){
      this.startDt = event.target.value;
      this.startDtToFirstOfMonth = this.getFirstDateOfMonth(this.startDt); 
    }

    getFirstDateOfMonth(dt){
        const regex = /(\-\d\d)$/;          
        var givenDateConvertedToFirst = dt.replace(regex,'-01');          
        return givenDateConvertedToFirst ;
    }
    @wire(getObjectInfo, { objectApiName: TASK_OBJECT })
    taskInfo;
    
    @wire(getPicklistValues,
        {
            //recordTypeId: '$taskInfo.data.defaultRecordTypeId',
            fieldApiName: Status_FIELD 
            
        }
    )
    statusValues;
//     taskData;
//     task;
//     error;
//     Status ='In Progress';
//     Subject ;

//     getTask(){
//         console.log('details '+details);
//     getTaskData({details : this.task})
//     .then(result => {
//         this.taskData = result;
//     })
//     .catch(error =>{
//         console.log('ERROR --> ', error);

//     })
// }

// get statusPickListValues() {
//     return [
//         { label: 'Not Started', value: 'Not Started' },
//         { label: 'In Progress', value: 'In Progress' },
//         { label: 'Completed', value: 'Completed' },
//         { label: 'Waiting on someone else', value: 'Waiting on someone else' },
//         { label: 'Deferred', value: 'Deferred' },
//     ];
// }

// handleTypeChange(event) {
//     this.Status = event.detail.value;
// }
// get subjectPickListValues() {
//     return [
//         { label: 'Call', value: ' Call' },
//         { label: 'Email', value: 'Email' },
//         { label: 'Send Letter', value: 'Send Letter' },
//         { label: 'Send Quote', value: 'Send Quote' },
//         { label: 'Other', value: 'Other' },
//     ];
// }
// handleChangeSubject(event){
//     this.subject = event.detail.value;
// }
}