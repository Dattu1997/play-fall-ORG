import { api, LightningElement, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createRelationTagItem from '@salesforce/apex/ListBuilderController.createRelationTagItem';
import getTagRelatedRelationships from '@salesforce/apex/ListBuilderController.getTagRelatedRelationships';     //IG-1046
import unassignRelationship from '@salesforce/apex/ListBuilderController.unassignRelationship';                 //IG-1046
import createRelTagItem from '@salesforce/apex/ListBuilderController.createRelTagItem';                         //IG-1046
import getFields from '@salesforce/apex/ListBuilderController.getFieldsFromMdt';                                //IG-1124
import getData from '@salesforce/apex/ListBuilderController.getData';                                           //IG-1130
import getRelationsByTagName from '@salesforce/apex/ListBuilderController.getRelationsByTagName';               //IG-1182
import getCustomSettings from '@salesforce/apex/ListBuilderController.getCustomSettings';                       //IG-1138
import getDomain from '@salesforce/apex/ListBuilderController.getDomain';

const infoIconSuccess = "standard:task2";
const infoIconAltTextForRecord = "This record is already added to the selected list";
const infoIconSuccessClass = "slds-icon slds-button_icon-inverse slds-icon_small slds-icon_container slds-icon-action-description";
const infoIconError = "standard:first_non_empty";
const infoIconAltTextForNoRecord = "A matching record could not be found in Salesforce";
const infoIconErrorClass = "slds-icon slds-button_icon-inverse slds-icon_small slds-icon_container slds-icon-action-close";

const successToast = "success";
const infoToast = "info";
const errorToast = "error";
const warningToast = "warning";
const addSuccessToastMsg = "Record Added Successfully!";
const addWarningToastMsg = "Record already exists!!";
const addErrorToastMsg = "Error while adding Record!";
const removeSucessToastMsg = "Record succesfully removed!";
const removeErrorToastMsg = "Error removing Record!";
const addInfoToastMsg = "Please select a Relationship!";
const loadErrorToastMsg = "Error while loading data";
const infoToastMsg = "No Record is selected!";
const infoCheckboxToastMsg = "This Record has already been added to this list";
const errorCheckboxToastMsg = "This Record cannot be added since it does not exist in Salesforce";

export default class ListBuilder extends NavigationMixin(LightningElement) {

    @api recordList;
    @api mode = 'Managed';              //IG-1046   //sets the mode of the table (default : Managed)
    @api tag;                           //IG-1046                 
    @api label = 'Relationship';        //IG-1124   //To fetch columns dynamically from metadata
    @api source;

    cardTitle = 'List Builder';     //Title of the Card
    data = [];                      //Display records in Mass-Add table
    dataManaged = [];               //Dispay records in Managed mode table
    columns;                        //Dynamic columns for Mass-Add mode
    columns2;                       //Dynamic columns for Managed mode
    isManageMode = false;           //To enable Manage mode   
    isMassAddMode = false;          //To enable Mass-Add mode   
    disableSearch = true;           //To disable Relationship search lookup

    checkRows = [];
    isSpinner = false;
    openModal = false;
    tagName;

    sortBy;
    sortDirection;
    
    relMsg = false;
    relNotAdded = false;
    relAdded = false;
    relExists = false;

    /* custom toast */
    isCustomToast = false;
    toastType;
    toastMsg;

    filterCondition = 'Name != null';
    
    tagId;
    relationshipId;
    tagRelationships = 0;
    tagSelected = false;
    createNewTag = false;

    isDisabled = true;
    selectedRelationships = 0;
    isApply = false;
    isRemove = false;    
    
    value = 'ViewAll';          //Radio button value - IG-1127

    /* IG-1130 */
    rows = [];
    
    /* lazy loading */
    allDataManaged =[];     //To store every record in managed mode
    recordListSize = 0;
    recordLimit = 0;
    rowCount = 0;
    applyBtnStyle = "border-radius: 12px;";
    navigateBtnStyle = "border-radius: 12px;";
    removeBtnStyle = "border-radius: 12px;";
    fieldsToDisp;
    whereClause;
    selectedRowsCount = 0;
    isSorted = false;                       // boolean to check if table is sorted
    validIds = [];                          // To store only valid SF Id's (Managed and Mass-Add)
    removePill = false;                     // To remove pill (on true pill cannot be removed)
    orgDomain = '';                         // To store salesforce org domain name to be used for redirected VF page
    tagRelatedRelationshipIds = [];         // Storing relationship Ids related to selected tag list
    readOnly = true;

    get options(){
        return [
            { label: 'View all records in selected list', value: 'ViewAll' },
            { label: 'Continue adding records to the selected list', value: 'ContinueAdd' }
        ];
    }

    connectedCallback(){
        this.isSpinner = true;
        let allIds = [];
        this.listBuilderSettings();
        if(this.mode === 'Mass Add'){
            this.isMassAddMode = true
            this.cardTitle += ' - Add Multiple Records'
            this.getDynamicFields();                                                //Fetching Fields dynamically
            if(this.recordList){
                /** here if recordList property is an object, then we are converting it to an array of loaded data objects */
                if(typeof this.recordList === 'object'){
                    let data = JSON.parse(JSON.stringify(this.recordList));
                    this.recordListSize = Object.keys(data).length;
                    this.recordList = [];
                    for (const key in data) {
                        this.recordList.push(data[key]);
                    }
                }else if(Array.isArray(this.recordList)){
                    this.recordList = JSON.parse(JSON.stringify(this.recordList));
                }
                if(this.source !== undefined && this.source === "Command_Center")           //if interface is Command center, hiding open list in command center button
                    this.navigateBtnStyle += " display:none;"
                
                if (this.recordList.length !== 0){
                    this.recordList.forEach(ele => {
                        if('SF_ID' in ele)
                            allIds.push(ele.SF_ID); 
                        else if('id' in ele)
                            allIds.push(ele.id);
                        else if('Id' in ele)
                            allIds.push(ele.Id);  
                    });
                    this.getDataFromDataBase(allIds);                               //Fetching data from DataBase based on Id's from recordList
                } else {
                    this.isSpinner = false;
                    // this.template.querySelector('c-lwc-lookup').setInputFocus();
                }
            }
        }else if(this.mode === 'Managed'){                                      //enabling default manage mode - rest is handled by tag selection
            if(this.source !== undefined && this.source === "Command_Center")           //if interface is Command center, hiding open list in command center button
                this.applyBtnStyle += " display:none;"

            this.isManageMode = true;
            this.cardTitle += ' - Manage List';
            this.getDynamicFields();
            console.log('Tag name: ', this.tag);
            if(this.tag){                                                    //if tag is available, loading table with available tag related relationships
                this.applyBtnStyle += ' display:none;'
                this.removePill = true;
                this.tagName = this.tag
                let tagEvent = { detail: { selectedId : "", selectedName : this.tagName } };
                this.getSelectedTag(tagEvent);
            }
            if((this.tagId === null || this.tagId === undefined || this.tagId === '') && (this.tag === '' || this.tag === undefined || this.tag === null)){
                setTimeout(() => {
                    this.template.querySelector('c-lwc-lookup').setInputFocus();
                }, "1000")
            }
        }
        /* if((this.tagId === null || this.tagId === undefined || this.tagId === '') && (this.tag === '' || this.tag === undefined || this.tag === null)){
            setTimeout(() => {
                this.template.querySelector('c-lwc-lookup').setInputFocus();
            }, "1000")
        } */
    }
    
    renderedCallback(){
        if(this.isMassAddMode && false){
            let style = document.createElement('style');
            style.innerText = '.slds-th__action{background-color: #dadada; color: black;}';
            this.template.querySelector("lightning-datatable[data-id=tableid]").appendChild(style);
        }
    }
    
    /**
     * @description : To fetch custom settings, which are used to display other fields in Relationship search and to filter Relationship records 
    */
    listBuilderSettings(){
        getCustomSettings({ })
        .then(data =>{
            this.fieldsToDisp = data['Relationship_Search_Display_Fields__c'];
            this.fieldsToDisp = this.fieldsToDisp.split(';')
            this.whereClause = data['Relationship_Search_Filter_Criteria__c'];
            this.rowCount = data['Scroll_Row_Count__c'];
            this.recordLimit = this.rowCount;
        }).catch(error => {
            console.error('settings error: ',error)
        })
    }

    @wire(getDomain)
    fetchDomain(data, error){
        if(data && data['data'] !== undefined){
            this.orgDomain = data['data'];
        }
        else if(error){
            console.error('fetchDomainerr: ',error);
        }
    }
    
    /**
     * @mode : Managed & Mass-Add
     * @description :   Dynamically fetching columns to pass to data table for both Manage and Mass-Add modes
     *                  This function invokes Apex getFieldsFromMdt() with a label of metadata record
     * @info : https://app.clickup.com/t/8406164/IG-1124
    */
    getDynamicFields() {
       getFields({ label : this.label})
       .then(result => {
            let columns = [];
            let iconObj = { fieldName: '', label: 'Info', initialWidth:45, type: 'button-icon', typeAttributes: {
                                                                                                    iconName: {fieldName: 'infoIcon'},
                                                                                                    alternativeText: {fieldName: 'iconAltText'},
                                                                                                    iconClass: {fieldName: 'iconClass'},
                                                                                                    type: 'text',
                                                                                                    variant:'bare'
                                                                                                }
                                                                                            }
            if(this.isMassAddMode)
                columns.push(iconObj);
            console.log('this columns-',columns);
            result.forEach( ele =>{
                console.log('ele--',ele);
                ele['label'] = ele['fieldLabel']
                delete ele['fieldLabel']
                if(ele.label === 'Name'){
                    ele['fieldName'] = 'nameLink';
                    ele['type'] = 'url';
                    ele['typeAttributes'] = {label : {fieldName : 'Name'}, target : '_blank'};
                }
                ele['sortable'] = 'true';
                ele['hideDefaultActions'] = 'true';
                columns.push(ele);
                console.log('cloumns-',columns);
            })
            this.columns = columns; 
            this.columns2 = columns;
            this.isSpinner = false;
        }).catch(error => {
            console.error('columns error: ', error);
            this.isSpinner = false;
        });
    }

    /**
     * @mode : Mass-Add
     * @description : Sends Id's to Apex and queries related records. This is to match dynamic Field Names
     * @param {Id} ids (Id's of All data)
     */
    async getDataFromDataBase(ids){  
        if(ids.length != 0){
            ids = JSON.stringify(ids);
            await getData({ label : this.label, idList : ids})
            .then(data =>{
                if(data.records.length !== 0){
                    data.records.forEach(item => {
                        this.validIds.push(item.Id);  
                        for(let key in item){
                            if(this.isValidUrl(item[key])){
                                this.columns.forEach(col=>{
                                    if(col['fieldName'] == key)
                                        col['type'] = 'url';
                                })
                            }
                            if(!isNaN(Date.parse(item[key])) && item[key].length >= 6)
                                item[key] = new Date(item[key]).toLocaleDateString();
                        }
                    })
                    this.recordList = [...data.records];
                    this.recordList = this.recordList.map(record =>{
                        if('Id' in record && this.validIds.includes(record.Id)){
                            let nameLink = `/${record.Id}`;
                            return {...record, nameLink};
                        }
                    })
                    this.validateIds(this.validIds);    //send all validIds to validate with existing all ids
                    this.data = this.recordList.slice(0, this.recordLimit);
                    this.isSpinner = false;
                }else{
                    this.validateIds();
                    this.data = this.recordList.slice(0, this.recordLimit);
                }
            }).catch(error =>{
                console.error('getData error: ', error);
            })
        }else{
            this.isSpinner = false;
        }
        this.template.querySelector('c-lwc-lookup').setInputFocus();
    }

    /**
     * @mode : Mass-Add
     * @description : To validate Id's (if a fetched record is invalid, an error icon is displayed with only Name field)
     * @param {Id} ids
     * @info : https://app.clickup.com/t/8406164/IG-1130
    */
    validateIds(ids){
        this.recordList.forEach(item =>{
            if('SF_ID' in item  || 'id' in item){
                //if id mismatches logic goes here...
                if('NAME' in item){
                    item['Name'] = item['NAME']
                    delete item['NAME']
                }
                item.infoIcon = infoIconError;
                item.iconAltText = infoIconAltTextForNoRecord;
                item.iconClass = infoIconErrorClass;
            } else{
                item.infoIcon = this.validIds.includes(item.Id) ? null : infoIconError;
                item.iconAltText = this.validIds.includes(item.Id) ? null : infoIconAltTextForNoRecord;
                item.iconClass = this.validIds.includes(item.Id) ? null : infoIconErrorClass;
            }
        })
    }

    noSearchValue
    /**
     * 
     * @param {event} event 
    */
    handleKeySearch(event){
        this.noSearchValue = JSON.parse(JSON.stringify(event.detail.noValues))
        if(this.noSearchValue){
            this.relMsg = true;
            setTimeout(() => {
                this.relMsg = false;
                this.noSearchValue = false;
            }, 3000);
        }
    }
    /**
     * @description : To control values from lookup search
     * @param {event} event 
    */
    getRecordIdFromChild(event){
        this.isSpinner = true;
        let lookUpRec = JSON.parse(JSON.stringify(event.detail));
        if(lookUpRec['selectedId'] != '' && lookUpRec['selectedId'].startsWith('001')){
            this.relationshipId = lookUpRec['selectedId']; 
        }
        else{
            this.tagId = lookUpRec['selectedId'];
            this.tagName = lookUpRec['selectedName'];
        }
        let relNotExist = true;
        let relExistOnItem = false;
        if(this.isManageMode){
            this.isSpinner = true;
            this.rows = [];
            this.template.querySelector("lightning-datatable[data-id=ldt]").getSelectedRows().forEach(ele =>{
                this.rows.push(ele.Id);
            });
            
            let allDataIds = [];
            this.allDataManaged.forEach(item =>{
                allDataIds.push(item.Id);
            });

            createRelTagItem({relaIds : this.relationshipId, tagId : this.tagId, label : this.label })
            .then(res =>{
                this.checkRows = [...this.rows];
                res.forEach(item =>{
                    if(!allDataIds.includes(item['Id'])){
                        this.validIds.push(item.Id)
                        this.recordLimit ++
                        for(var key in item){
                            if(item[key].length >= 6 && !isNaN(Date.parse(item[key])))
                                item[key] = new Date(item[key]).toLocaleDateString();
                        }
                        this.allDataManaged = [item, ...this.allDataManaged];
                        this.isSpinner = false;
                        this.showToast(successToast, addSuccessToastMsg);
                    }else{
                        this.isSpinner = false;
                        this.showToast(warningToast, addWarningToastMsg);
                    }
                    this.allDataManaged = this.allDataManaged.map( data =>{
                        let nameLink = `/${data.Id}`;
                        return {...data, nameLink};
                    })
                    this.recordListSize = this.allDataManaged.length;
                    this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
                })
            }).catch(error =>{
                console.error('createRelTagItem error: ', error);
                this.showToast(errorToast, addErrorToastMsg);
                this.isSpinner = false;
            })
        }
        else if(this.isMassAddMode){
            if(this.relationshipId){
                if(this.tagRelatedRelationshipIds.includes(this.relationshipId)){
                    relExistOnItem = true; 
                    this.relationshipId = null;  
                    this.relMsg = true;
                    this.relExists = true;
                    setTimeout(()=> {
                        this.relMsg = false;
                        this.relExists = false;
                    }, 3000);
                }
                this.recordList.forEach(obj =>{
                    if(obj.Id === this.relationshipId){
                        this.showCustomToast(warningToast, addWarningToastMsg);
                        relNotExist = false;
                        this.relationshipId = null;
                    }
                });
                this.isSpinner = false;
            }
            /* this.rows = [];
            this.template.querySelector("lightning-datatable[data-id=tableid]").getSelectedRows().forEach(ele =>{
                this.rows.push(ele['Id'])
            }) */
            if(this.relationshipId && relNotExist && !relExistOnItem)
                this.getRelationship(this.relationshipId, this.rows);
            
            if(this.tagId === '' || this.tagId === null || this.tagId === undefined){
                if(this.recordList){
                    this.recordList.forEach(ele =>{
                        if(!('SF_ID' in ele || 'id' in ele)){
                            ele.infoIcon =null;
                            ele.iconClass = null;
                            ele.iconAltText = null;
                        }
                    })
                    this.data = this.recordList.slice(0, this.recordLimit);
                }
                
                this.applyBtnStyle = 'border-radius: 12px;';
                if(this.source !== "Command_Center")
                    this.navigateBtnStyle = 'border-radius: 12px;';
                
                this.template.querySelector(".outer").style.opacity = "0.5";
                this.template.querySelector(".outer").style['pointer-events'] = 'none';
                this.tagSelected = false;
                this.rows = [];
                this.checkRows = [];
                this.tagRelatedRelationshipIds = [];
                this.selectedRowsCount = this.checkRows.length;
                this.disableSearch = true;
                this.isSpinner = false;
                this.isDisabled = true;
            }else if(!lookUpRec['selectedId'].startsWith('001')){
                getTagRelatedRelationships({tagId : this.tagId, label : this.label})
                .then(result =>{
                    if(result.length !== 0){
                        this.recordList.forEach(ele =>{
                            if(ele.hasOwnProperty('Id')){
                                result.forEach(item =>{
                                    if(ele.Id == item.Id){
                                        ele.iconAltText = infoIconAltTextForRecord;
                                        ele.infoIcon = infoIconSuccess;
                                        ele.iconClass = infoIconSuccessClass;
                                    }else{
    
                                    }
                                })
                                if(ele.infoIcon !== infoIconSuccess)	
                                    this.rows.push(ele.Id);
                            }
                        })
                        this.tagRelatedRelationshipIds = result.map(r => r.Id);
                    }else{
                        this.rows = this.recordList.map(r => {
                            if(r.infoIcon === null)
                                return r.Id
                            });
                    }
                    this.checkRows = this.rows;
                    this.selectedRowsCount = this.checkRows.length;
                    this.tagRelationships = result.length;
                    this.data = this.recordList.slice(0, this.recordLimit)
                    this.template.querySelector(".outer").style.opacity = 1;
                    this.template.querySelector(".outer").style['pointer-events'] = 'all';
                    this.tagSelected = true;
                    this.isDisabled = false;
                    this.applyBtnStyle += " background-color:#0176d3;";
                    if(this.source !== "Command_Center")
                        this.navigateBtnStyle += " background-color:#0176d3";                       

                    this.disableSearch = false;
                    this.isSpinner = false;
                })
                .catch(error =>{
                    console.error('getTagRelatedRelationships error: ', JSON.stringify(error));
                    this.isSpinner = false;
                    this.showCustomToast(errorToast, loadErrorToastMsg);
                })
            }
        }           
    }

    /**
     * @mode : Mass-Add
     * @description : Fetches Relationship from search lookup and adds to table
     * @param {Id} RelationshipId (Id from Relationship search lookup)
     * @param {Array} rows (selected rows Ids)
     */
    getRelationship(RelationshipId, rows){
        
        // this.data = [];
        this.isSpinner = true;
        let idList = [RelationshipId];
        getData({label : this.label, idList : idList, tagId : this.tagId})
        .then(data =>{
            this.recordLimit += data.records.length;
            data.records.forEach(obj =>{
                obj.nameLink = `/${obj.Id}`;
                if(!this.validIds.includes(obj.Id))
                    this.validIds.push(obj.Id);
                
                if(data.relationshipExists){ 
                    obj.infoIcon = infoIconSuccess;
                    obj.iconAltText = infoIconAltTextForRecord;
                    obj.iconClass = infoIconSuccessClass;
                }else
                    this.rows.push(obj.Id);
                
                for(let key in obj){
                    if(this.isValidUrl(obj[key])){
                        this.columns.forEach(col=>{
                            if(col['fieldName'] == key)
                                col['type'] = 'url';
                        })
                    }
                    if(obj[key].length >= 6 && !isNaN(Date.parse(obj[key])))
                        obj[key] = new Date(obj[key]).toLocaleDateString();
                }
                this.recordList.unshift(obj);
            });
            rows.forEach(r =>{
                if(!this.rows.includes(r))
                    this.rows.push(r);
            })
            this.checkRows = [...this.rows];
            this.data = this.recordList.slice(0, this.recordLimit);
            this.recordListSize = this.recordList.length;
            this.relationshipId = null;
            this.selectedRowsCount = this.checkRows.length;
            this.isSpinner = false;
            this.relMsg = true;
            this.relAdded = true;
            setTimeout(()=> {
                this.relMsg = false;
                this.relAdded = false;
            }, 3000);
            
        }).catch(error =>{
            console.error('getRelationship error ',error);
            this.isSpinner = false;
            this.relMsg = true;
            this.relNotAdded = true;
            setTimeout(()=> {
                this.relMsg = false;
                this.relNotAdded = false;
            }, 3000);
        })
    }
    
    handleApply(){
        this.openModalWindow();
        this.isApply = true
    }
    fromAddToManage = false;
    enableManageTable = false;
    handleSave(){
        let checkedRelationships = [...this.checkRows];
        this.isSpinner = true;
        if(checkedRelationships.length === 0){
            this.showCustomToast(infoToast, infoToastMsg);
            this.isSpinner = false;
        }else{
            this.closeModal();
            createRelationTagItem({selectedRelationshipIds : checkedRelationships, tagId : this.tagId})
                .then(result =>{
                    if(this.value === 'ViewAll'){
                        this.cardTitle = this.cardTitle.replace(' - Add Multiple Records','');
                        this.closeModal();
                        this.validIds = this.tagRelatedRelationshipIds = this.checkRows = [];
                        this.selectedRowsCount = this.checkRows.length;
                        this.isDisabled = false;
                        this.enableManageTable = true;
                        this.isMassAddMode = false;
                        this.fromAddToManage = true;
                        this.mode = 'Managed';
                        let tags = { detail: { selectedId : this.tagId, selectedName : this.tagName } };
                        this.getSelectedTag(tags);
                        this.connectedCallback();
                    }else if(this.value === 'ContinueAdd'){
                        this.tagRelationships += result.length;
                        this.tagRelatedRelationshipIds = result.map(r => r.Id);
                        this.rows = [];
                        if(this.recordList.length !== 0){   
                            this.recordList.forEach(rec=>{
                                if(rec.hasOwnProperty('Id')){
                                    result.forEach(res =>{
                                        if(rec.Id === res.Id){
                                            rec.infoIcon = infoIconSuccess;
                                            rec.iconAltText = infoIconAltTextForRecord;
                                            rec.iconClass = infoIconSuccessClass;
                                        }
                                    })
                                }
                            })
                        }
                        
                        this.checkRows = this.rows;
                        this.selectedRowsCount = this.checkRows.length;
                        this.data = this.recordList.slice(0, this.recordLimit);
                        this.isSpinner = false;
                        this.showCustomToast(successToast, addSuccessToastMsg); 
                    }
                }).catch(error =>{
                    console.error('handleSave error : ',error);
                    this.isSpinner = false;
                    this.showCustomToast(errorToast, addErrorToastMsg);
                })
        }
    }

    /**
     * @mode : Managed & Mass-Add
     * @description : function to handle row checkbox selection.
     * @param {event} event 
     * @info : 
    */
    allUncheck = false; 
    allcheck = false;
    f = false;
    deselectedRow = [];
    async handleSelectedRow(event) {  
        console.log('In handleSelectedRow - fromSort: ',this.fromSort);
        
        if(this.isMassAddMode && !this.fromSort){                     // Row selection handling for Mass-Add
            let selectedRows = event.detail.selectedRows;   
            var u = selectedRows.map(s => s.Id );
            console.log('mass add row selection: ', u);
            var d = [];

            let i = selectedRows.map(re => re.infoIcon !== null);
            i = i.filter(e => e === true)
            
            if(i.length === this.data.length){
                console.log('in if');
                if(!this.f){
                    this.checkRows = this.rows = [];
                    this.f = true;
                }else{
                    this.rows = this.recordList.map(row => {
                        let rtnId;	
                        if(this.validIds.includes(row.Id) && (row.infoIcon === null || row.infoIcon === undefined) && !d.includes(row.Id))
                            rtnId = row.Id;	
                                                    
                        return rtnId;	
                    });	
                    this.rows = this.rows.filter((row)=> row !== undefined & !d.includes(row));
                    this.f = false;
                }
            }
            else if(selectedRows.length > 1 && selectedRows.length === this.data.length){
                console.log('in else if 1');
                this.data.forEach(e =>{
                    if(!u.includes(e.Id)){
                        d.push(e.Id);
                    }
                });
                this.rows = await this.recordList.map(row => {
                    let rtnId;	
                    if(this.validIds.includes(row.Id) && (row.infoIcon === null || row.infoIcon === undefined) && !d.includes(row.Id))
                        rtnId = row.Id;	
                                            	
                    return rtnId;	
                });	
                this.rows = this.rows.filter((row)=> row !== undefined & !d.includes(row));
                this.allUncheck = false;
            }else if(this.allUncheck){
                console.log('in else if 2');
                let deselected = [];
                this.recordList.forEach(e =>{ 
                    if(!u.includes(e.Id)){
                        deselected.push(e.Id);  
                    }
                })
                this.rows = await this.recordList.map(row => {	
                    let rtnId;		
                    if(this.validIds.includes(row.Id) && (row.infoIcon === null || row.infoIcon === undefined)){	
                        rtnId = row.Id;	
                    }	
                    else if(row.infoIcon === infoIconSuccess && !deselected.includes(row.Id)){	
                        this.showCustomToast(infoToast, infoCheckboxToastMsg);	
                    }else if(!this.validIds.includes(row.Id)){	
                        this.showCustomToast(infoToast, errorCheckboxToastMsg);	
                    }	
                    return rtnId;	
                });	
                this.rows = this.rows.filter((r) => r !== undefined & !deselected.includes(r));
                if(this.rows.length === 0) this.b = [];
                if(this.b.length != 0) this.rows = this.rows.concat([...new Set([...this.b])])// related to sorting
            }else if(selectedRows.length < this.recordLimit && selectedRows.length !== 0){
                console.log('in else if 3');
                console.log('deselcted: ', this.deselectedRow);
                let deselected = [];
                this.data.forEach(e =>{ 
                    if(!u.includes(e.Id)){
                        deselected.push(e.Id);  
                    }
                })
                this.rows = this.recordList.map(row => {	
                    let rtnId;		
                    if(this.validIds.includes(row.Id) && (row.infoIcon === null || row.infoIcon === undefined)){	
                        rtnId = row.Id;	
                    }
                    return rtnId;	
                });	
                this.rows = this.rows.filter((r) => r !== undefined & !deselected.includes(r));
                this.b = [...this.rows];
                if(this.deselectedRow.length > 0){
                    this.rows = this.b = [...this.deselectedRow];
                }
            }else if(selectedRows.length === 0){
                console.log('deselecting all');
                this.checkRows = this.rows = this.b = [];
                this.allUncheck = true;
            }
            if(this.deselectedRow.length > 0){
                this.rows.forEach(r=>{
                    if(!this.deselectedRow.includes(r)){
                        this.deselectedRow.push(r);
                    }
                })
                this.deselectedRow.forEach(d =>{
                    if(!this.b.includes(d))
                        this.b.push(d);
                })
                this.rows = [...this.deselectedRow];
                this.deselectedRow = [];
            }
            console.log('rows:--- ', this.rows, 'b: ', this.b);
            this.checkRows = [...new Set([...this.rows, ...this.b])];
            console.log('checkRows: ', this.checkRows);
            this.selectedRowsCount = this.checkRows.length
            // this.isSpinner = false;
        }
        else if(this.isManageMode && !this.fromSort){                 // Row selection handling for Managed Mode
            let selectedRows = event.detail.selectedRows;
            const selectedIds = selectedRows.map(s => s.Id );
            console.log('selectedROws: ', selectedIds);
            let uncheckedRows = [];
            // this.allUncheck = true;
            if(selectedRows.length > 1 && selectedRows.length === this.recordLimit){
                console.log('in if');
                console.log('deselceted-- ', this.deselectedRow);
                this.dataManaged.forEach(e =>{
                    if(!selectedIds.includes(e.Id)){
                        uncheckedRows.push(e.Id);
                    }
                });
                this.rows = this.allDataManaged.map(row => row.Id);
                this.rows = this.rows.filter(r => !uncheckedRows.includes(r));
                this.allcheck = true;
                if(this.deselectedRow.length > 0){
                    this.rows = this.deselectedRow;
                }
            }else if( selectedRows.length < this.recordLimit && selectedRows.length !== 0 && !this.allcheck){
                console.log('in else if ');
                this.dataManaged.forEach(e =>{
                    if(!selectedIds.includes(e.Id)){
                        uncheckedRows.push(e.Id);
                    }
                });
                this.rows = this.dataManaged.map(r => r.Id);
                this.rows = this.rows.filter(r => r !== undefined & !uncheckedRows.includes(r));

            }else if(this.allcheck && selectedRows.length > 0){
                console.log('in else if 2');
                this.b = [...new Set([...this.b])]
                console.log('b 123: ',this.b);
                this.dataManaged.forEach(e =>{
                    if(!selectedIds.includes(e.Id)){
                        uncheckedRows.push(e.Id);
                    }
                });
                this.rows = this.allDataManaged.map(d => d.Id);
                this.rows = this.rows.filter(r => r !== undefined & !uncheckedRows.includes(r));
                // this.allcheck = false;
                if(this.b.length > 1 && this.b !== 0){
                    console.log('this.rows-',this.rows);
                    console.log('this.b-',this.b);
                    //this.rows = [...new Set([...this.b])]

                }
                this.b = [...this.rows];
            }
            else{
                console.log('deselecting all');
                this.b = [];
                this.rows = [];
                this.allcheck = false;
            }
            // console.log('deselected: ', this.deselectedRow);
            if(this.deselectedRow.length > 0){
                //console.log('in deselected if--',this.deselectedRow);
                this.rows.forEach(r=>{
                    if(!this.deselectedRow.includes(r)){
                        //console.log('in second if--',this.deselectedRow);
                        this.deselectedRow.push(r);
                    }
                })
                this.deselectedRow.forEach(d =>{
                    if(!this.b.includes(d))
                        this.b.push(d);
                })
                this.rows = [...this.deselectedRow];
                this.deselectedRow = [];
            }
            //console.log('rows:--- ', this.rows, 'b: ', this.b);
            this.checkRows = [...new Set([...this.rows, ...this.b])];
            //console.log('checkRows: ', this.checkRows);
            this.selectedRowsCount = this.checkRows.length; 
            
        }
        if(this.fromSort){
            console.log('in formSort--');
            this.fromSort = false;
            //console.log('rows2: ',this.rows);
            if(this.rows.length !== 0){
                this.deselectedRow = this.rows; //Id of row when de-selected due to sorting...
                // this.checkRows = this.rows;
            }
            if(this.deselectedRow.length !== 0){
                this.rows = this.deselectedRow;
                
            }
            //console.log('rows3: ', this.rows);
            this.checkRows = [...new Set([...this.rows, ...this.b])];
            console.log('b: ', this.b);
            //console.log('checkRows: ',this.checkRows);
            this.selectedRowsCount = this.checkRows.length
            
        }
        // return undefined;
    }
    b = [];
    handleSort(event){
        // this.checkRows = [];
        console.log('Rows: ', this.rows);
        console.log('checkRows: ', this.checkRows);
        this.isSpinner = true;
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    fromSort = false;
    sortData(fieldName, dir){
        let SortingData
        if(this.isMassAddMode)
            SortingData = JSON.parse(JSON.stringify(this.recordList));
        else if(this.isManageMode)
            SortingData = JSON.parse(JSON.stringify(this.allDataManaged));
        
        let keyValue = (a) => {
            if(a[fieldName] === '/'+a.Id){
                return a['Name'].toLowerCase();
            }
            if(!isNaN(Date.parse(a[fieldName]))){
                return new Date(a[fieldName]);
            }
            if(typeof a[fieldName] === 'string')
                return a[fieldName].toLowerCase();
            else
                return a[fieldName];       
        };

        let isReverse = dir === 'asc' ? 1: -1;

        SortingData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        if(this.isMassAddMode){
            this.recordList = [...SortingData];
            this.data = this.recordList.slice(0, this.recordLimit);
        }
        else if(this.isManageMode){
            this.allDataManaged = [...SortingData];
            this.checkRows = this.rows;
            this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
        }
        this.isSorted = true;
        this.fromSort = true;
        this.isSpinner = false;
        this.handleSelectedRow();
    }

    showToast(type, message) {
		const toastEvent = new ShowToastEvent({
			message : message,
			variant : type,
			mode: 'dismissable',
		});
		this.dispatchEvent(toastEvent);
	}

    /* For custom toast notifications */
    showCustomToast(type, message){
        this.openModalWindow();
        this.isCustomToast = true;
        this.toastType = type;
        this.toastMsg = message;
        setTimeout(() => {
            this.isCustomToast = false;
            this.closeModal();
        }, 3000);
    }
    get iconName(){
        return 'utility:'+this.toastType;
    }
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.toastType + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.toastType;
    }

    /**
     * @mode : Managed
     * @description :   Invoked when a Tag is selected in search lookup,
     *                  gets Tag Id, Name and fetches related Relationship records from data base
     * @param {event} event 
     * @info : IG-1046
    */
    getSelectedTag(event){
        this.isSpinner = true;
        var childEvent = JSON.parse(JSON.stringify(event.detail));
        this.disableSearch = false;
        if(!childEvent['selectedId'].startsWith('001') && childEvent['selectedId']){ 
            console.log('This console should not be displayed if in Command center');
            if(!this.applyBtnStyle.includes(' background-color:#0176d3'))
                this.applyBtnStyle += " background-color:#0176d3;";

            this.tagId = childEvent['selectedId'];
            this.tagName = childEvent['selectedName'];
            this.getTagRelatedRelations();
        }else if(childEvent['selectedName'] && childEvent['selectedName'] !== undefined){
            console.log('getting Relationships by tag names');
            this.applyBtnStyle += " background-color:#0176d3;";
            this.getRelationsByTagName(childEvent['selectedName']);
        }else{
            let commandCenter = false;
            if(this.source === 'Command_Center') commandCenter = true;

            if(!commandCenter){
                this.applyBtnStyle = "border-radius: 12px;";
                this.enableManageTable = false;
            }else{
                this.allDataManaged = this.dataManaged = [];
                this.enableManageTable = true;
            }
            this.disableSearch = true;
            this.isDisabled = true;
            this.recordLimit = this.rowCount;
            this.allcheck = false;
            this.validIds = [];
            this.checkRows = [];
            this.rows = []; 
            this.recordListSize = this.selectedRowsCount = 0;
            this.isSpinner = false;
        }
    }
    
    /**
     * @mode : Managed
     * @description : To get Relationships related to selected Tag in Managed mode
     *               Queries related Relationships from Apex and loads into table.
    */
    getTagRelatedRelations(){
        this.recordListSize = 0;
        this.allDataManaged = [];
        getTagRelatedRelationships({ tagId: this.tagId, label: this.label})
        .then(result=>{
            this.recordListSize = result.length;
            if (result.length != 0) {
                result.forEach(e =>{
                    this.validIds.push(e.Id);
                    for(var key in e){
                        if(typeof e[key] === 'object' && key == 'Owner'){
                            e['OwnerId'] = e[key]['Name'];
                            // delete e['Owner Name']
                        }
                        if(e[key].length >= 6 && !isNaN(Date.parse(e[key])))
                            e[key] = new Date(e[key]).toLocaleDateString();
                        
                        if(this.isValidUrl(e[key])){
                            this.columns2.forEach(col=>{
                                if(col['fieldName'] == key){
                                    col['type'] = 'url';
                                }
                            })
                        }
                    }
                })
                result = result.map(res =>{
                    let nameLink = `/${res.Id}`;
                    return {...res, nameLink};
                })
                this.allDataManaged = JSON.parse(JSON.stringify(result));
                this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
                this.buttonStyle += " background-color:#ba0517;"
                this.isDisabled = false;
                this.enableManageTable = true;
            } else {
                this.buttonStyle += " background-color:#ba0517;"
                this.isDisabled = false;
                this.enableManageTable = true;
                this.dataManaged = [];
            }
            this.isSpinner = false;
        }).catch(error=>{
            this.isSpinner = false;
            console.error('getTagRelatedRelationships Error: ', error);
        })
    }

    isValidUrl(_string){
        const matchPattern = /^(?:\w+:)?\/\/([^\s\.]+\.\S{2}|localhost[\:?\d]*)\S*$/;
        return matchPattern.test(_string);
    }

    /**
     * @mode : Managed
     * @description : Function to get Relationships related to Tag_list based on Tag_list name value
     * @param {String} tagName
    */
    getRelationsByTagName(tagName){
        console.log('getting relations by tagname: ', tagName);
        if(tagName){
            getRelationsByTagName({tagName : tagName, label : this.label})
            .then(result =>{
                this.tagId = result.recordId;
                this.recordListSize = result.records.length;
                console.log('fetched Relationships: ', result.records);
                if (result.records.length != 0) {
                    result.records.forEach(e =>{
                        this.validIds.push(e.Id);
                        for(var key in e){
                            /* if(typeof e[key] === 'object'&& key == 'Owner'){
                                e['OwnerId'] = e[key]['Name'];
                            } */
                            if(e[key].length >= 6 && !isNaN(Date.parse(e[key])))
                                e[key] = new Date(e[key]).toLocaleDateString();
                            
                            if(this.isValidUrl(e[key])){
                                this.columns2.forEach(col=>{
                                    if(col['fieldName'] == key){
                                        col['type'] = 'url';
                                    }
                                })
                            }
                        }
                    })
                    result.records = result.records.map( res => {
                        let nameLink = `/${res.Id}`;
                        return {...res, nameLink};
                    })
                    this.allDataManaged = JSON.parse(JSON.stringify(result.records));
                    console.log('this.allDataManaged: ' + JSON.stringify(this.allDataManaged));
                    console.log('this.recordLimit: ' + this.recordLimit);
                    this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
                    console.log('this.dataManaged: ' + JSON.stringify(this.dataManaged));
                    this.buttonStyle += " background-color:#ba0517;"
                    this.isDisabled = false;
                    this.enableManageTable = !this.isDisabled;
                } else {
                    console.log('No Relationships for selected Tag');
                    this.buttonStyle += " background-color:#ba0517;"
                    this.isDisabled = false;
                    this.enableManageTable = !this.isDisabled;
                    this.dataManaged = [];
                }
                this.isSpinner = false;
            }).catch(error =>{
                console.error('getRelationsByTagName Error: ',error);
                this.isSpinner = false;
            })
            
        }
    }

    handleRemove(){
        this.closeModal();
        this.validIds = [];
        let selectedRel = [];
        this.template.querySelector("lightning-datatable[data-id=ldt]").getSelectedRows().forEach(ele =>{
            this.recordLimit --;
            selectedRel.push(ele.Id);
        })
        let relIds = this.checkRows;
        if(selectedRel.length != 0 && this.tagId != ''){
            this.isSpinner = true;
            unassignRelationship({relList : relIds, tagId : this.tagId, label : this.label})
            .then(res =>{
                if(res.length > 100){
                    this.recordLimit = this.rowCount;
                }else
                    this.recordLimit = res.length;
                
                res.forEach(i =>{
                    this.validIds.push(i.Id);
                    for(let key in i){
                        if(i[key].length >= 6 && !isNaN(Date.parse(i[key]))){
                            const date = new Date(i[key]).toLocaleDateString();
                            i[key] = date;
                        }
                    }
                })
                res = res.map(result =>{
                    let nameLink = `/${result.Id}`;
                    return {...result, nameLink};
                })
                this.allDataManaged = [...res];
                this.recordListSize = this.allDataManaged.length;
                if(this.isSorted){
                    let keyValue = (a) => {
                        if(a[this.sortBy] === '/'+a.Id){
                            return a['Name'].toLowerCase();
                        }
                        if(!isNaN(Date.parse(a[this.sortBy])))
                            return new Date(a[this.sortBy]);
                        if(typeof a[this.sortBy] === 'string')
                            return a[this.sortBy].toLowerCase();
                        else
                            return a[this.sortBy];
                    };
                    let isReverse = this.sortDirection === 'asc' ? 1: -1;
                    this.allDataManaged.sort((x, y) => {
                        x = keyValue(x) ? keyValue(x) : ''; 
                        y = keyValue(y) ? keyValue(y) : '';
                       
                        return isReverse * ((x > y) - (y > x));
                    });
                    this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
                }else{
                    this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
                }
                this.isSpinner = false;
                this.showToast(successToast, removeSucessToastMsg);
            }).catch(err =>{
                console.error('unassignRelationship error ',err);
                this.showToast(errorToast, removeErrorToastMsg);
                this.isSpinner = false;
            })
        }
    }

    /**
     * @mode : Mass-Add
     * @description :   To handle the radio button value in Apply button popup
     *                  The selected value sets the confirm button behaviour in Mass-Add mode
     * @param {event} event 
     * @info : https://app.clickup.com/t/8406164/IG-1127
     */
    handleRadioChange(event){
        this.value = event.detail.value
    }
    
    /**
     * @description :   Function handling lazy loading data for both Manage and Mass-Add mode
     *                  Adds 50 records to table when scrolled all the way down
     * @param {event} event 
     * @info : https://app.clickup.com/t/8406164/IG-1141
    */
    handleMoreData(event){
        this.isSpinner = true;
        event.preventDefault();
        if(this.isManageMode){
            if(this.dataManaged.length >= this.recordListSize){
                event.target.isLoading = false;
            }else{
                this.checkRows = [...this.rows]
                this.recordLimit = this.recordLimit + this.rowCount;
                this.recordLimit = (this.recordLimit > this.recordListSize) ? this.recordListSize : this.recordLimit;
                this.dataManaged = this.allDataManaged.slice(0, this.recordLimit);
            }
        }
        else if(this.isMassAddMode && this.tagSelected){
            if(this.data.length >= this.recordListSize){
                event.target.isLoading = false;
            }else{
                this.checkRows = [...this.rows];
                this.recordLimit = this.recordLimit + this.rowCount;
                this.recordLimit = (this.recordLimit > this.recordListSize) ? this.recordListSize : this.recordLimit;
                this.data = this.recordList.slice(0, this.recordLimit);
            }
        }
        this.isSpinner = false;
        event.target.isLoading = false;
    }

    openModalWindow(){
        if(this.isManageMode){
            console.log('removing rows: ', this.checkRows);
            this.selectedRelationships = this.checkRows.length;
            if(this.selectedRelationships === 0){
                this.showToast(infoToast, addInfoToastMsg);
            }else{
                this.isRemove = true;
                this.openModal = true;
            }
        }
        else if(this.isMassAddMode){
            this.selectedRelationships = this.selectedRowsCount;
            this.openModal = true;
        }
    }

    closeModal(){
        this.openModal = false;
        this.isApply = false;
    }

    /**
     * @description : Navigates the User to Command Center with selected Tag List
     * @info : https://app.clickup.com/t/8406164/IG-1126
    */
     navigateToCommandCenter(){
        const pageUrl = window.location.href;
        if(pageUrl.includes('vf.force.com/apex')){
            let tagN = this.tagName.replaceAll(" ","%20");
            const path = 'https://' + this.orgDomain +'/lightning/n/CommandCenter?Copilot_CC__tagName='+tagN;
            this.dispatchEvent(new CustomEvent('navigate', {
                detail : { path },
                bubbles : true,
                composed : false
            }));
        }else{
            let url = '/lightning/n/CommandCenter?Copilot_CC__tagName=' + this.tagName;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                    attributes: {
                    url: url
                }
            },
            true
            );
        }
     }
}