import { LightningElement } from 'lwc';
import getMetadataRecord from '@salesforce/apex/MetaDataHelper.getMetadataRecord';
import handleUpsert from '@salesforce/apex/MetadataService.handleUpsert';
export default class CustomMetaData extends LightningElement {

    value = '';
    columns = [];
    showTable = false;
    data = [];
    metaDataAll = [];
    tableData = [];
    fldItemValues = [];
    fullName;
    label;
    fieldWithValues;
    savedraftValues = [];
    allData = [];
    recordName;
    recordId;
    get metaRecords(){
        return [
                    { label : 'Account Field', value :'Account_Field__mdt'},
                    { label :'List Builder Field', value : 'List_Builder_Field__mdt'},
                    {label : 'List Builder Object', value : 'List_Builder_Object__mdt',editable: true},
                    {label: 'New Demo Meta', value: 'New_Demo_Meta__mdt'}
                ];
    }
    

    handleMetaRecordChange(event){
        this.showTable = true;
        this.value = event.detail.value;
        // this.recordId = event.target.value;
        // console.log('recordId--',this.recordId);
        console.log('handleMetaRecordChange-'+ this.value);
        
        
            getMetadataRecord({metadataName : this.value, label : ''})
            .then(result =>{
                let columns = [];
                var tableData = [];
                console.log('result: ',result);//columns = [{label: , fieldname: }];
                console.log('result2: ',result.fields);
                result.fields.forEach( ele =>{   
                     let str = ele.replace(/__c/g,"");
                     let str1 = str.replace(/_/g," ");
                    if(ele != 'id' && ele != 'developername' && ele != 'masterlabel' && ele != 'namespaceprefix' && ele != 'language' ){
                    let obj = {label: str1, fieldName: ele, hideDefaultActions: true, editable: true}
                        columns.push(obj);
                        
                    }
                })
                console.log('columns',columns);
                this.columns = [...columns];  
                console.log('data--',result.records);
                this.allData = [...result.records];
                result.records.forEach(element =>{
                        let ary = {};
                        for(let k in element){
                              ary[k.toLowerCase()] = element[k];  
                              
                        }
                        tableData.push(ary);
                })
            
                this.data = [...tableData];
                }).catch(error =>{
                console.log('error--',error);
            })

    }

    saveHandle(event){
        console.log('event--',JSON.stringify(event));
        this.allData = event.detail.draftValues;
        console.log('console --> ', JSON.stringify(this.allData));
        
        handleUpsert({fullName : this.value, label: 'Type Demo', fieldWithValues: JSON.stringify(this.savedraftValues)})
        .then(result =>{
            console.log('result in save--',result);
        }).catch( error =>{
            console.log('error--',error);
        })
    }

}