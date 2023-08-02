/**
 * @File Name          : lxc_customDataLoader.js
 * @Description        : 
 * @Author             : Anup Kage
 * @Group              : 
 * @Last Modified By   : Anup Kage
 * @Last Modified On   : 07-06-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/6/2020   Anup Kage     Initial Version
**/
import { LightningElement, api, wire,track} from 'lwc';
import mappingFields from '@salesforce/apex/customDataLoaderController.getMappingFields';
import insertRecords from '@salesforce/apex/customDataLoaderController.insertRecords';
import getCSVFileUploadObject from '@salesforce/apex/customDataLoaderController.getCSVFileUploadObject';
import fetchAllRecords from '@salesforce/apex/customDataLoaderController.fetchAllRecords';
import getRelatedObject from '@salesforce/apex/customDataLoaderController.getRelatedObject';
import createUpdateMetadata from '@salesforce/apex/CreateUpdateMetadataUtils.createUpdateMetadata';
import getObjFields from '@salesforce/apex/CreateUpdateMetadataUtils.getObjFields';
import getObjFieldsMetadata from '@salesforce/apex/CreateUpdateMetadataUtils.getObjFieldsMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/customDataLoaderController.uploadFile';
import getDocumentTypeList from '@salesforce/apex/customDataLoaderController.getDocumentTypeList';
import getAppLabel from '@salesforce/apex/CreateUpdateMetadataUtils.getAppLabel';
import LightningConfirm from "lightning/confirm";
// To Support xlsxc
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx"; // https://salesforcelightningweb.com/#multiple-worksheets-in-excel-using-lwc


export default class Lxc_customDataLoader extends LightningElement {
	@api recordId;
	@api columnNameByField // Used to Map records fields
	@api objectApiName;
	@api csvApplicationLabel;
	@api csvHeaderLabel;
	@api filterCondition;
	@api filterType;
	
	renderedCallbackRunOnce = false;
	csvObject;
	fileName;
	filesUploaded = [];
	recordsArray;
	errorList = [];
	successList = [];
	errorCSVText;
	successCSVText;
	templateCSVText;
	columnTypeByField;
	enableDropDownBtn = true;
	MAX_FILE_SIZE;
	MAX_RECORD_SIZE = 200;  // default 200
	ShowProgressResult = false;
	ShowProgressBar = false;
	ShowBothFileOpption = false;
	ShowContentFileOpption = false;
	showDataFileOpption = false;
	isApplicationExists = false;
	isApplication = false;
	showInput = false;
	ShowProgressValue = 0;
	error;
	fileData;
	DropDownValue = [];
	selectDocumentTypeOptions = [];
	contentTypeOfFile;
	isSelectContentFile = false;
	populatingButtonGroup = false;
	showModalNoAppliction = false
	populatingBothButton = false;
	showDownloadOption = false;
	disableDataFile = false;
	uploadedFileNames = [];
	showModalPopup = false;
	filesUploadedlst = [];
	contentFilesUploadedlst = [];
	fileNames = [];
	HilightButton;
    countAllFile;
	isShowSpinner = false;
	isDataTypeDisable = true;
	isContentTypeDisable = true;
	selectedTypeValue;
	showModalForDataFile = false;
	dropDownValues = false;
	showApplication = false;
	objDropDown;
	isTypeListBuilder = false;
	@track clearDocumentType;
	@track includeData = false;
	@api get recordsPerCall() {
		return this.MAX_RECORD_SIZE;
	}
	set recordsPerCall(value) {
		this.MAX_RECORD_SIZE = value;
	}
	@wire(mappingFields, { csvObjectLabel: '$csvApplicationLabel' })
	fieldsRecords(result) {
		if (result.data) {
			this.isApplicationExists = result.data.isApplicationExists;
			console.log('this==>',this.isApplicationExists);
			if(this.isApplicationExists){
				this.showModalNoAppliction = true;
				console.log('isApplicationExists===>',this.isApplicationExists);
				this.includeData = result.data.includeData;
				this.columnTypeByField = JSON.parse(result.data.mapOfColumnType);
				console.log('ShowBothFileOpption==>', result.data.showBothFileOpption);
				console.log('showDataFileOpption==>', result.data.showDataFileOpption);
				console.log('ShowContentFileOpption==>', result.data.showContentFileOpption);
				this.columnNameByField = result.data.mapOfColumnName;
				this.ShowBothFileOpption = result.data.showBothFileOpption;
				this.ShowContentFileOpption = result.data.showContentFileOpption;
				this.showDataFileOpption = result.data.showDataFileOpption;
				//this.documentTypeList =  result.data.documentTypeLst;
				this.createTemplateForUpload();
			}
			else{
				this.showDataFileOpption = true;
			}
		} else if (result.error) {
			this.error = result.error;
			this.ShowErrorToastMessage(result.error);
		}
	}
	@wire(getCSVFileUploadObject, { csvObjectLabel: '$csvApplicationLabel' })
	objectData(result) {
		if (result.data) {
			this.csvObject = result.data;
		}
		else if (result.error) {
			console.error('error---->', JSON.parse(JSON.stringify(result.error)))
			this.ShowErrorToastMessage(result.error);
			this.error = result.error;
		}
	}
	@wire(getDocumentTypeList, {csvObjectLabel: '$csvApplicationLabel'})
		lists({ error, data }) {
			if (data) {
				console.log('data----> ',data);
				for(var i=0;i<data.length;i++){
					console.log('list----> ',data[i]);
					this.selectDocumentTypeOptions.push({'label': data[i],
															'value': data[i]});
					
					console.log('selectDocumentTypeOptions----> ',this.selectDocumentTypeOptions);
				}
			} else if (error) {
				console.error(error);
			}
		}
	renderedCallback() {

		Promise.all([loadScript(this, workbook + "/xlsx.full.min.js")])
			.then(() => {
				console.log("success");
			})
			.catch(error => {
				console.error("failure", JSON.parse(JSON.stringify(error)));
			});

		let element = this.template.querySelector("lightning-input[data-id='fileUploader']");
		if (element !== null && element !== undefined && !this.renderedCallbackRunOnce) {
			let style = document.createElement('style');
			style.innerText = `drop_zone-lxc_custom-data-loader .slds-file-selector__body {
				height: 5vh;
				padding: 0%;
			 }`;
			element.appendChild(style);
			this.renderedCallbackRunOnce = true;
		}
	}
	
	handleFileUpload(event) {
		if(!this.isApplicationExists){
			this.showModalNoAppliction = true;
		}
         console.log('inside handleFileUpload',event.target.files);
		console.log('event.target.files.length------- ', event.target.files.length);
		 var dataFileName = '';
		for(var i=0; i< event.target.files.length; i++){
			let file = event.target.files[i];
			var createdId = 'file'+i;
			var databtnid = 'DataBtnId'+i;
			var conBtnId = 'conBtnId'+i;
			
			if(this.ShowBothFileOpption){
				this.populatingButtonGroup = true;
				this.populatingBothButton = true;
				this.fileNames = event.target.files[i].name;
			}
			let contenttype = event.target.files[i].name.split('.').pop().toLowerCase();
			let inputCmp = this.template.querySelector("lightning-input[data-id='fileUploader']");
			this.contentTypeOfFile = contenttype;
			
			this.showDownloadOption = false;

			this.showModalPopup = true;// For Enable Model Popup
			
			if (contenttype === 'csv' || contenttype === 'xls' || contenttype === 'xlsm' || contenttype === 'xlsx' || contenttype === 'xlt') {
				inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
				this.isDataTypeDisable = false;
				this.isContentTypeDisable = true;
			}
			else{
				this.isDataTypeDisable = true;
				this.isContentTypeDisable = false;
			}
			this.uploadedFileNames.push({Name: file.name, id:createdId,DataBtnId:databtnid, ConBtnId:conBtnId, isDataDisable:this.isDataTypeDisable, isContentDisable:this.isContentTypeDisable});
			console.log('uploadedFileNames----- ', this.uploadedFileNames);
		
			// if(this.ShowBothFileOpption || this.showContentFileOpption){
			// 	this.handleContentFileUpload(event);//
			// }
			if(this.ShowBothFileOpption || this.showDataFileOpption){
				inputCmp.reportValidity();
				if (contenttype === 'csv') {
					console.log('------csv------');
					//this.fileName = event.target.files[0].name;
					this.filesUploaded.push(event.target.files[i]);
					if( event.target.files.length-1 != i){
						dataFileName += event.target.files[i].name +', ';
					}else{
						dataFileName += event.target.files[i].name ;
					}
					
					if(this.ShowBothFileOpption == false &&  this.showDataFileOpption == true){
						this.readAllData();
						this.showModalForDataFile = true;
					}
					//this.readAllData();
				} 
				else if (contenttype === 'xls' || contenttype === 'xlsm' || contenttype === 'xlsx' || contenttype === 'xlt') {
					console.log('------ ',contenttype+' -------',event.target.files[0].name );
					console.log('----files--length-------',event.target.files.length );
					if( event.target.files.length-1 != i){
						dataFileName += event.target.files[i].name +', ';
					}else{
						dataFileName += event.target.files[i].name ;
					}
					
					
					this.filesUploaded.push(event.target.files[i]);
					if(this.ShowBothFileOpption == false &&  this.showDataFileOpption == true){
						this.readExcelFile();
						this.showModalForDataFile = true;
					}
					//this.readExcelFile();
				}
				else{
					console.log('------diff file------');
					this.contentFilesUploadedlst.push(event.target.files[i]);
					this.handleContentFileUpload();
				}
			}
		}
		//console.log('------dataFileName------------------',dataFileName);
		this.fileName = dataFileName;
	}

	handleContentFileUpload() {
		console.log('handleContentFileUpload====195 ',this.contentFilesUploadedlst.length);
		// if (event.target.files.length > 0) {
			// this.ShowProgressBar = false;
			// this.isSelectContentFile = true;
			console.log('filesUploadedlstupdates 12==== ',this.filesUploadedlst);
            for(var i=0; i< this.contentFilesUploadedlst.length; i++){
                let file =this.contentFilesUploadedlst[i];
                let reader = new FileReader();
				
                reader.onload = e => {
				
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesUploadedlst.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});

                };
                reader.readAsDataURL(file);
            }
			if(this.ShowBothFileOpption == false &&  this.showDataFileOpption == true){
				this.showErrorToast();
			}
    }
    insertContentFile(){
		console.log('filesUploadedlstupdates8==== ',this.filesUploadedlst);
		console.log('filesUploadedlstupdates8 length==== ',this.filesUploadedlst.length);
		console.log('selectedTypeValue ',this.selectedTypeValue);
				uploadFile({files: this.filesUploadedlst,recordId: this.recordId, csvObjectLabel:this.csvApplicationLabel,contentDocumentType:JSON.stringify(this.DropDownValue)})
					.then(result => {
						this.isShowSpinner = true;
						this.showSucessToast();
						this.filesUploadedlst = [];
						this.contentFilesUploadedlst = [];
						this.DropDownValue = [];
						window.location.reload();						
					})
					.catch(error => {
						console.log('error===> ',error);
						this.filesUploadedlst = [];
						this.contentFilesUploadedlst = [];
						this.DropDownValue = [];
						// this.isSelectContentFile = false;
						// this.populatingButtonGroup = false;
						// this.populatingBothButton = false;
						// this.showErrorToast(this.comboBOXIDuploadedFileNames.toString());
						// this.enableDropDownBtn = true;
					});
	}
	/**
	 * Read CSV FILE 
	 */
	readAllData() {
		//var allText = new Array();
		var dataAdd = [] ;
		let allText;
		console.log('----length--- ',this.filesUploaded.length);
		for (let i = 0 ,p = Promise.resolve(); i <  this.filesUploaded.length; i++) {	
			let file = this.filesUploaded[i];
			p = p.then(_ => new Promise(resolve => {
				//console.log('i---- ',i);
				this.fileReader = new FileReader();
				this.fileReader.onloadend = (() => {
					 allText = this.fileReader.result;
					console.log('----allText---- ',allText);
					resolve(allText);
					this.convertCSVDataIntoObject(allText);
				});
				
					this.fileReader.readAsText(file);
					
				
				}
			));
			
		}
	}
	
	readExcelFile() {
		const XLSX = window.XLSX;
		let self = this;
		var reader = new FileReader();

		reader.onload = function (e) {
			console.log('---reader.onload---');
			var data = e.target.result;
			var workbook = XLSX.read(data, {
				type: 'binary'
			});

			workbook.SheetNames.forEach(function (sheetName) {
				var XL_row_toCSV = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
				self.convertCSVDataIntoObject(XL_row_toCSV);
			})
		};

		reader.onerror = function (ex) {
			console.error(ex)
		};
		let fileContentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
		let convertFileToBlob = new Blob(this.filesUploaded, {type: fileContentType}); //converting .xlsx file to blob
		reader.readAsBinaryString(convertFileToBlob);
	}

	TableData = [];
	csvColumns = [];
	convertCSVDataIntoObject(allText) {
		console.log('===convertCSVDataIntoObject===');
		let allTextLines = this.CSVToArray(allText, ',');
		console.log('allTextLines.>>>>',allTextLines);
		this.csvColumns = [...allTextLines[0]];
		console.log('allTextLines',allTextLines);
		let headers = allTextLines[0]; // get header
		let columnNameByField = this.columnNameByField;
		let columnTypeByField = this.columnTypeByField;
		let recordsArray = [], arrayCount = 0;
		let lines = [];
		const csvObject = this.csvObject;
		let errorList = [];
		this.countAllFile =  allTextLines.length;
		// Inside validate the required fields.
		
		for (let i = 1; i < allTextLines.length; i++) {
			let valueOfallTextLines = allTextLines[i];
			var str = '';
			var data = [];
			var firstQuote = 0;
			valueOfallTextLines.forEach(ele => {
				if (ele.startsWith('"')) {
					str = str + ele.replace('"', '');// replacing from starting only
					firstQuote = 1;
				}
				else if (ele.endsWith('"')) {
					str = str + ',' + ele.replace('"', '');// replacing from Ending only
					firstQuote = 0;
				}
				else if (firstQuote === 1) {
					str = str + ',' + ele; //adding middle value only 
				}
				else {
					str = ele;
				}

				if (firstQuote === 0) {
					data.push(str);
					str = '';
				}
			})

			if (data.length == headers.length) {
				let record = {};
				record.attributes = {};
				record.attributes.type = csvObject.Object_API_Name__c;
				if (csvObject.Parent_Record_Id__c) {
					record[csvObject.Parent_Record_Id__c.toLowerCase()] = this.recordId;
				}
				let countforBlankRecords = 0; // To find the end of csv file
				let isRequiredError = false;
				for (let j = 0; j < headers.length; j++) {
					if (data[j] == '' || data[j] == undefined || data[j] == null) {
						countforBlankRecords++;
					}
					const headerName = headers[j].toLowerCase();
					let field = columnNameByField[headerName];
					console.log('field--',field);
					if (field) {
						if (field.Required__c && (data[j] == undefined || data[j] == null || data[j] == '')) {
							isRequiredError = true;
							record.ErrorMessage = 'Required Field Value is missing: ' + field.Field_API_Name__c;
						} else {
							console.log('field: ' + field.Field_API_Name__c + '; value: ' + data[j]);
							switch (columnTypeByField[headerName]) {
								case 'BOOLEAN':
									if (data[j].toLowerCase() == 'true' || data[j] == 1) {
										record[field.Field_API_Name__c.toLowerCase()] = true;
									} else if (data[j].toLowerCase() == 'false' || data[j] == 0) {
										record[field.Field_API_Name__c.toLowerCase()] = false;
									}
									else {
										record[field.Field_API_Name__c.toLowerCase()] = null;
									}
									break;
								case 'DATE':
									if(data[j] != undefined){
										try{
											let dtVale = new Date(data[j]);
											record[field.Field_API_Name__c.toLowerCase()] = dtVale.getFullYear()+'-'+(dtVale.getMonth()+1)+'-'+dtVale.getDate();
										}catch(de){
											
										}
									}
									break;
								case 'DATETIME':
									if(data[j] != undefined){
										try{
											let dtVale = new Date(data[j]);
											record[field.Field_API_Name__c.toLowerCase()] = dtVale.getFullYear()+'-'+(dtVale.getMonth()+1)+'-'+dtVale.getDate()+'T'
																									+dtVale.getHours()+':'+dtVale.getMinutes()+':'+dtVale.getSeconds()+'.'+dtVale.getMilliseconds();
										}catch(de){
											
										}
									}
									break;
								default:
									record[field.Field_API_Name__c.toLowerCase()] = data[j];
									break;
							}
						}
					} else if (headerName == 'id' && data[j] !== '' && data[j] !== null && data[j] != undefined) {
						record['id'] = data[j];
					}
					console.log('->>>1', record);
				}

				console.log('->>>', record);
				if (headers.length === countforBlankRecords) {  //on end of csv file
					break;
				}
				if (!isRequiredError) {
					lines.push(record); // upload list
				} else {
					errorList.push(record); // ERROR list
				}
				console.log('errorlist 426------ ', this.errorList);
			}

			// recordsArray is used to set how many itrations required to insert all records. 
			// EX inserting 500 records and MAX_RECORD_SIZE= 200. then it contains 3 rows. each row contions max 200 records.
			if (lines.length === this.MAX_RECORD_SIZE) {
				recordsArray[arrayCount] = lines;
				lines = [];
				arrayCount++;
			}
		}
		// if records are less then Max size
		if (lines.length > 0) {
			recordsArray[arrayCount] = lines;
			lines = [];
		}
		
		this.recordsArray = recordsArray;
		this.setupProgressBar();
		this.errorList = errorList;
		if (this.recordsArray.length === 0) {
			this.endAllProcess();
		} else {
			this.performDMLAction()
		}
	}
	/*
		using promise we are calling apex class and passing records,
	*/
	performDMLAction() {
		console.log('====performDMLAction======');
		let recordsArray = this.recordsArray;
		let self = this;
		let breakOnError = false;
			for (let i = 0, p = Promise.resolve(); i < recordsArray.length && !breakOnError; i++) {
				p = p.then(_ => new Promise(resolve => {
					// let isError = false;
					insertRecords({ recordList: JSON.stringify(recordsArray[i]), objectApiName: this.csvObject.Object_API_Name__c })
						.then(data => {
							console.log('data--',data);
							 self.handleResponse(data);
							 self.calculateProgress(i + 1);
							// this.populatingButtonGroup = false;
							// this.populatingBothButton = false;
							this.filesUploaded = [];
							// this.filesUploadedlst = [];
							//this.recordsArray = null;
							
							resolve();
						}).catch(error => {
							// breakOnError = true;
							// self.ShowErrorToastMessage(error);
							// this.populatingButtonGroup = false;
							// this.populatingBothButton = false;
							 this.recordsArray = null;
							 this.filesUploaded = [];
							// this.filesUploadedlst = [];
							// let message = error.body.message;
							// self.resetFileUploader();
							self.calculateProgress(i + 1);
							
							resolve();
							// p.reject();
							// isError = true;
							// break;	
						})
				}
				));
			}
	}
	calculateProgress(count) {
		console.log('Inside calculateProgress=== ',count);
		console.log('this.recordsArray.length---',this.recordsArray);
		if(this.recordsArray != undefined && this.recordsArray != null){
		
			this.ShowProgressValue = Math.floor((count / this.recordsArray.length) * 100);
			console.log('in if---',this.ShowProgressValue);
		}
		if (this.ShowProgressValue >= 100) {
			this.endAllProcess();
		}
		this.showDownloadOption = this.errorCSVText ? true : (this.successCSVText ? true : false);
	}
	endAllProcess() {
		this.showToast();
		this.resetFileUploader();
		this.dispatchEvent(new CustomEvent('customrefresh'));
	}
	resetFileUploader() {
		this.errorCSVText = this.convertArrayOfObjectsToCSV(this.errorList);
		this.successCSVText = this.convertArrayOfObjectsToCSV(this.successList);
	}
	setupProgressBar() {
		console.log('INside setupProgressBar');
		this.errorList = [];
		this.successList = [];
		//this.template.querySelector('lightning-input').disabled = true;
		this.ShowProgressResult = true;
		this.ShowProgressBar = true;
		this.ShowProgressValue = 0;
		this.errorCSVText = null;
		this.successCSVText = null;
	}
	handleResponse(data) {
		if (data.errorRecordList.length > 0) {
			this.errorList = this.errorList.concat(data.errorRecordList);
		}
		if (data.successRecordList.length > 0) {
			this.successList = this.successList.concat(data.successRecordList);
		}
		
	}
	convertArrayOfObjectsToCSV(responseList) {
		// declare variables
		var csvStringResult, counter, keys, columnDivider, lineDivider;

		// check if "objectRecords" parameter is null, then return from function
		if (responseList == null || !responseList.length) {
			return null;
		}
		// store ,[comma] in columnDivider variabel for sparate CSV values and 
		// for start next line use '\n' [new line] in lineDivider varaible  
		columnDivider = ',';
		lineDivider = '\n';
		let record = responseList[0];
		let objKeys = Object.keys(record);
		keys = objKeys.filter(e => e !== 'attributes');

		// in the keys valirable store fields API Names as a key 
		// this labels use in CSV file header  
		// keys = ['FirstName', 'LastName', 'Department', 'MobilePhone', 'Id'];

		csvStringResult = '';
		csvStringResult += keys.join(columnDivider);
		csvStringResult += lineDivider;

		for (var i = 0; i < responseList.length; i++) {
			counter = 0;

			for (var sTempkey in keys) {
				var skey = keys[sTempkey];

				// add , [comma] after every String value,. [except first]
				if (counter > 0) {
					csvStringResult += columnDivider;
				}
				csvStringResult += '"' + responseList[i][skey] + '"';
				counter++;

			} // inner for loop close 
			csvStringResult += lineDivider;
		}// outer main for loop close 

		// return the CSV formate String 
		return csvStringResult;
	}
	downloadSuccessCSV(event) {
		this.downloadCSVFile(this.successCSVText, 'SuccessExportData.csv');
		// var hiddenElement = document.createElement('a');
		// hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.successCSVText);
		// hiddenElement.target = '_self'; // 
		// hiddenElement.download = 'SuccessExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
		// document.body.appendChild(hiddenElement); // Required for FireFox browser
		// hiddenElement.click(); // using click() js function to download csv file
	}
	downloadErrorCSV(event) {
		this.downloadCSVFile(this.errorCSVText, 'ErrorExportData.csv');
		// var hiddenElement = document.createElement('a');
		// hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.errorCSVText);
		// hiddenElement.target = '_self'; // 
		// // let fileName = 'ErrorExportData' + new Date() ;
		// hiddenElement.download = 'ErrorExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
		// document.body.appendChild(hiddenElement); // Required for FireFox browser
		// hiddenElement.click(); // using click() js function to download csv file
	}
	showToast() {
		let type = 'success'
		if (this.errorList.lenght > 0 && this.successList.length === 0) {
			type = 'error'
		}
		let strmessage = 'Data Insertion Completed. Success: ' + this.successList.length + ' Error: ' + this.errorList.length;
		console.log('ERROR=====',this.errorList)
		let totalSizeOfSucessndError = this.successList.length +  this.errorList.length;
		console.log('countAllFile---> ',this.countAllFile);
		console.log('totalSizeOfSucessndError---> ',totalSizeOfSucessndError);
		if(this.countAllFile == totalSizeOfSucessndError){
		    const event = new ShowToastEvent({
		       	message: strmessage,
			    variant: type,
			    mode: 'dismissable'
		    });
		    this.dispatchEvent(event);
	    }
	}
	ShowErrorToastMessage(error) {
		console.log('error---> ',error);
		this.dispatchEvent(new CustomEvent('customrefresh'));
		const event = new ShowToastEvent({
			message: error.body.message,
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}
	createTemplateForUpload() {
		let keys = Object.keys(this.columnNameByField);
		  
		console.log('columnNameByField---', this.columnNameByField);
		console.log('keys---',keys);
		let dummyList = [];
		let record = {};
		keys.forEach(key => {
			record[key] = '';
		});
		dummyList.push(record);
		//Check order on dumylist if we are getting correct order then task is done else We have to write a sorting  code in js
		this.templateCSVText = this.convertArrayOfObjectsToCSV(dummyList);

	}
		
	downloadtemplateCSV(event) {
		let elementIncludeData = this.template.querySelector("lightning-input[data-name='IncludeData']")
		if (this.filterType != 'None' && elementIncludeData && elementIncludeData.checked) {
			fetchAllRecords({ csvObjectLabel: this.csvApplicationLabel, filterType: this.filterType, filterCondition: this.filterCondition, recordId: this.recordId })
				.then(result => {
					this.downloadCSVFile(result, 'templateUpload.csv');
				}).catch(error => {
					this.ShowErrorToastMessage(error);
				});
		} else {
			
			this.downloadCSVFile(this.templateCSVText, 'templateUpload.csv');
		}
	}
	downloadCSVFile(filedata, fileName) {
		var hiddenElement = document.createElement('a');
		hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(filedata);
		hiddenElement.target = '_self'; // 
		hiddenElement.download = fileName;  // CSV file Name* you can change it.[only name not .csv] 
		document.body.appendChild(hiddenElement); // Required for FireFox browser
		hiddenElement.click(); // using click() js function to download csv file
	}
	get showDownloadDataCheckbox() {
		return this.filterType !== 'None';
	}

	/**
	 * CSVToArray parses any String of Data including '\r' '\n' characters,
	 * and returns an array with the rows of data.
	 * @param {String} CSV_string - the CSV string you need to parse
	 * @param {String} delimiter - the delimeter used to separate fields of data
	 * @returns {Array} rows - rows of CSV where first row are column headers
	 * https://stackoverflow.com/questions/36288375/how-to-parse-csv-data-that-contains-newlines-in-field-using-javascript
	*/
	
	CSVToArray(CSV_string, delimiter) {
		delimiter = (delimiter || ","); // user-supplied delimeter or default comma

		var pattern = new RegExp( // regular expression to parse the CSV values.
			( // Delimiters:
				"(\\" + delimiter + "|\\r?\\n|\\r|^)" +
				// Quoted fields.
				"(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
				// Standard fields.
				"([^\"\\" + delimiter + "\\r\\n]*))"
			), "gi"
		);

		var rows = [[]];  // array to hold our data. First row is column headers.
		// array to hold our individual pattern matching groups:
		var matches = false; // false if we don't find any matches
		// Loop until we no longer find a regular expression match
		while (matches = pattern.exec(CSV_string)) {
			var matched_delimiter = matches[1]; // Get the matched delimiter
			// Check if the delimiter has a length (and is not the start of string)
			// and if it matches field delimiter. If not, it is a row delimiter.
			if (matched_delimiter.length && matched_delimiter !== delimiter) {
				// Since this is a new row of data, add an empty row to the array.
				rows.push([]);
			}
			var matched_value;
			// Once we have eliminated the delimiter, check to see
			// what kind of value was captured (quoted or unquoted):
			if (matches[2]) { // found quoted value. unescape any double quotes.
				matched_value = matches[2].replace(
					new RegExp("\"\"", "g"), "\""
				);
			} else { // found a non-quoted value
				matched_value = matches[3];
			}
			// Now that we have our value string, let's add
			// it to the data array.
			rows[rows.length - 1].push(matched_value);
		}
		return rows; // Return the parsed data Array
	}

	
	handleUploadFiles() {
		console.log('==handleUploadFiles==');
		let allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputFld) => {
                inputFld.reportValidity();
                return validSoFar && inputFld.checkValidity();
            }, true);
		// console.log('filesUploaded==== 642 ',this.filesUploaded.length);
		console.log('contentFilesUploadedlst====  ',this.contentFilesUploadedlst.length);
		let dataFilesLength = this.filesUploaded.length;
		console.log('dataFilesLength==== ',dataFilesLength);
		if(dataFilesLength > 0 && allValid === true){
			for(let i=1;i <= dataFilesLength; i++){
				console.log('=======',i)
				if(this.contentTypeOfFile === 'xls' || this.contentTypeOfFile === 'xlsm' || this.contentTypeOfFile === 'xlsx' || this.contentTypeOfFile === 'xlt'){
					console.log('----reading excel file')
					this.readExcelFile();
				}
				if(this.contentTypeOfFile === 'csv'){
					console.log('-----reading all data')
					this.readAllData();
				}
			}
		}
		console.log('--allValid.checked----',allValid)
		if(this.contentFilesUploadedlst.length > 0 && allValid === true){
			console.log('selectedTypeValue======',this.selectedTypeValue);
			if(this.selectedTypeValue){
				this.insertContentFile();
				 
			}
		}
	}
	showSucessToast() {
		let type = 'success'
		let strmessage = ' File was uploaded successfully';
		const event = new ShowToastEvent({
			message: strmessage,
			variant: type,
			mode: 'dismissable',
			
		});
		this.dispatchEvent(event);
		//this.isShowSpinner = true;
	}

	showErrorToast() {
		let type = 'error'
		let strmessage = 'Files was Not uploaded successfully';
		const event = new ShowToastEvent({
			message: strmessage,
			variant: type,
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}
	handleDataFiles(event){
		var contentFileBTNId = event.target.value;
		
		var comboBOXID = this.template.querySelector("lightning-combobox[data-id='"+contentFileBTNId+"']");
		comboBOXID.disabled = true;
		comboBOXID.value = null;
		
		//Changing bg-color Of Button Group
		var contentBtnId = event.currentTarget.dataset.difid;
		console.log('contentBtnId ', contentBtnId);
		var contentFileBtnUncheck = this.template.querySelector("[data-btnid='"+contentBtnId+"']");
		console.log('contentFileBtnUncheck ', contentFileBtnUncheck);
		contentFileBtnUncheck.checked = false;

	}
	handleContentFiles(event){
		console.log('handleContentFiles----------------- ');
		
		var contentFileBTNId = event.target.value;//event.currentTarget.dataset.ConBtnId;
		
		var comboBOXID = this.template.querySelector("lightning-combobox[data-id='"+contentFileBTNId+"']");
		comboBOXID.disabled = false;
		
		//Changing bg-color Of Button Group
		var dataFileBtnId = event.currentTarget.dataset.difid;
		console.log('dataFileBtnId 1', dataFileBtnId);
		var dataFileBtnUncheck = this.template.querySelector("[data-btnid='"+dataFileBtnId+"']");
		console.log('dataFileBtnUncheck 1', dataFileBtnUncheck);
		dataFileBtnUncheck.checked = false;
	}
	
	handleChange(event) {
		
		let selectDropDownValue = event.target.value;
		this.selectedTypeValue = selectDropDownValue;
		console.log('selectDropDownValue>>>>>>', selectDropDownValue);
		//console.log('bw: id = ' + event.currentTarget.id);
		// output: bw: id = undefined
		console.log('bw: id = ' + event.currentTarget.dataset.id);
		for (let i = 0; i < this.uploadedFileNames.length; i++) {
			if(this.uploadedFileNames[i].id == event.currentTarget.dataset.id){
				for(let j = 0; j < this.DropDownValue.length; j++){
					console.log('this.DropDownValue[j] = ' , this.DropDownValue[j]['fileName']);
					if(this.DropDownValue[j]['fileName'] == this.uploadedFileNames[i].Name){
						this.DropDownValue.pop(j);	
					}	
				}
				this.DropDownValue.push({fileName: this.uploadedFileNames[i].Name, type: selectDropDownValue});
			}

		}
		/*if(!this.DropDownValue.includes(selectDropDownValue)){
			this.DropDownValue.push(selectDropDownValue);
		}*/
		console.log('Dropdownvalues>>>>>>',this.DropDownValue);
    }
	showErrorToastForSelectCorrectFile() {
		let type = 'error'
		let strmessage =  'Please select content File';
		const event = new ShowToastEvent({
			message: strmessage,
			variant: type,
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}

	showSucessToastMetadata() {
		let type = 'success'
		let strmessage = ' template created successfully';
		const event = new ShowToastEvent({
			message: strmessage,
			variant: type,
			mode: 'dismissable',
			
		});
		this.dispatchEvent(event);
	}
	closeModal() {    
        // to close modal window set showModalPopup value as false
        this.showModalPopup = false;
		this.populatingButtonGroup = false;
		this.ShowProgressResult = false;
		this.uploadedFileNames = [];
		this.filesUploaded = [];
		this.contentFilesUploadedlst = [];
		this.showModalForDataFile = false;
		this.showModalNoAppliction = false;
		this.csvColumns = [];
		this.TableData = [];
    }

	handleOpenMdtTable(){
		this.showModalNoAppliction = false;
		this.showModalPopup = false;
		this.showApplication = true;
		
	}

	handleCloseModalApp(){
		this.showModalNoAppliction = false;
	}

	handleCloseModal(){
		this.showApplication = false;
		this.showModalNoAppliction = false;
		this.showApplication = false;
		this.isShowModalSpinner = false;
		// this.dataTable = false;
	}

	handleRecord(event){
		console.log('event--',event.target.value);
	}
	
	objectValues = [];
	//isReadOnly = true;
	@track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
	handleClick(){
		this.dropDownValues = true;
		this.isTypeListBuilder = true;
		this.isValue = false;
		// this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
		getRelatedObject({recordId : this.recordId})
		.then(result =>{
			console.log('result123===>',result);
			if(result === 'Account'){
				this.objDropDown = [{label : 'Account', iconName : 'standard:account'},{label : 'Contact', iconName : 'standard:contact'},{label : 'Opportunity', iconName : 'standard:opportunity'}]
			}
			else if(result === 'Contact'){
				this.objDropDown = [{label : 'Account', iconName : 'standard:account'},{label : 'Contact', iconName : 'standard:contact'},{label : 'Opportunity', iconName : 'standard:opportunity'}]
			}
			else if(result === 'Opportunity'){
				this.objDropDown = [{label : 'Account', iconName : 'standard:account'},{label : 'Contact', iconName : 'standard:contact'},{label : 'Opportunity', iconName : 'standard:opportunity'}]
			}
			console.log('dropDownValues--',this.objDropDown);    
		}).catch(error =>{
			console.log('error',error);
		})
	}

	valueObj;
	isValue;
	dataTable = false;
	objFields = [];
	iconName;
	fieldLookUp = [];
	showInputLookUp = false;
	async onSelect(event){
		this.dropDownValues = false;
		this.dataTable = true;
		this.showInputLookUp = true;
		this.isTypeListBuilder = true;
		let ele = event.currentTarget;
		let selectedName = ele.dataset.name;
		this.valueObj = selectedName;		
		console.log('selectedName--',selectedName);
		this.objFields = await this.getFields(this.valueObj);
		console.log('objFields: '+this.objFields); //[]
		
		this.isValue = false;
		console.log('------',this.csvColumns);
		this.csvColumns.forEach(col =>{
			let obj = {};
			obj.column = col; 
			if(this.objFields.includes(col)){
				obj.field = col;
			}
			this.TableData.push(obj);
		});
		console.log('tabledata----982',this.TableData);
		this.objDropDown.forEach( element =>{
			if(element.label == selectedName){
				this.iconName = element.iconName;
			}
		});
		if(this.isShowPill){
            this.isValue = false;
        }else{
            this.isValue = true;
        }
		this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
	}

	fieldAPIName;
	fieldslabel;
	async getFields(){
		//let fieldsLabel = [];
		await getObjFields({objectName : this.valueObj})
		.then(result =>{
			console.log('filelds -lookup-',JSON.parse(JSON.stringify(result)));
			console.log('fields result--0000345',JSON.stringify(result.fieldAPIName));
			console.log('fields result--0000',JSON.stringify(result.fieldlabel));
			this.fieldsLabel = [...result.fieldlabel];
			this.fieldAPIName = result.fieldAPIName
			let filedLookUpValues = result.fieldLookUp;
			let a = [];
			let b = [];
			let fieldValues = [];
			filedLookUpValues.forEach( el =>{
				console.log('el--',el);
				if(el){
					b = el.replace(/[{()}]/g, '');
					var obj = {label : b, value : b}
					if(b !== this.valueObj && !a.includes(b)){
						a.push(b);
						fieldValues.push(obj);
						console.log('this.fieldLookUp---==',this.fieldLookUp);
					}
					
					
				}
			});
			this.fieldLookUp = [...fieldValues];
		}).catch(error =>{
			console.log('fields error--',error);
		});
		return this.fieldsLabel;

	}

	handleRemovePill() {
        if(this.isRemovePill){
            console.log('in romove pill--');
        }else{
            console.log('in else remove--');
            this.isValue = false;
			this.dataTable = false;
			this.TableData = [];
			this.fieldsData = [];
        }
    }

	handlePillRemove(){
		if(this.isRemovePill){
            console.log('in romove pill--');
        }else{
            console.log('in else remove--');
			this.isValueTable = false;
			this.fieldsData = [];
        }
	}

	result;
	success;
	labelValue;
	metaDataApplication = [];
	metaDataObject = [];
	metaDataField = [];
	objMetaUpload = [];
	objMeta = [];
	objMetaValues = [];
	isSpinner = false;
	handleSaveTable(){
		//this.isSpinner = true;
		getObjFieldsMetadata({objectName : ['Application__mdt', 'CSV_File_Upload_Object__mdt']})
		.then(result =>{
			console.log('res== in meta data',result);
			this.metaDataApplication = result['Application__mdt'];
			this.metaDataObject = result['CSV_File_Upload_Object__mdt'];
			this.metaDataApplication.forEach(ele => {
				if(ele != 'id' && ele != 'developername' && ele != 'masterlabel' && ele != 'namespaceprefix' && ele != 'language' && ele != 'qualifiedapiname' && ele != 'label' ){
					let metaDataApp = {};
					metaDataApp = ele;
					this.objMeta.push(metaDataApp);
				}
			}) 
			console.log('this.objMeta---',this.objMeta);
			var mapObj = [];
			this.objMeta.forEach(aa =>{
				mapObj.push({[aa] : this.valueObj});
			})
			console.log('objMetaValues--1234',JSON.stringify(mapObj));
			this.labelValue = this.csvApplicationLabel.replace(' ','_');
			createUpdateMetadata({fullName :'Application.'+this.labelValue, label : this.labelValue, fieldVal : mapObj})
			.then(result =>{
				console.log('result---123',result);
				if(result){
					this.metaDataObject.forEach(val => {
						if(val != 'id' && val != 'developername' && val != 'masterlabel' && val != 'namespaceprefix' && val != 'language' && val != 'qualifiedapiname' && val != 'label' ){
							let metaDataApp = {};
							metaDataApp = val;
							this.objMetaUpload.push(metaDataApp);
						}
					})
					var mapObjUpload = [];
					this.labelValue = this.csvApplicationLabel.replace(' ','_');
					this.objMetaUpload.forEach(aa =>{
						if(aa === 'application__c' || aa === 'Application__c'){
							mapObjUpload.push({[aa] : this.labelValue});
						}
						else{
							mapObjUpload.push({[aa] : this.valueObj});
						}
					})
					console.log('mapObjUpload--1234',JSON.stringify(mapObjUpload));
					createUpdateMetadata({fullName :'CSV_File_Upload_Object.'+this.labelValue, label : this.labelValue, fieldVal : mapObjUpload})
					.then(result =>{
						console.log('result123---',result);
						if(result){
							this.handleMetaDataUpdate();
							
						}
					}).catch(error =>{
						console.log('error123--',error);
					})
				}
			}).catch(error =>{
				console.log('error--',error);
			})
		}).catch(error =>{
			console.log('error',error);
		})
	}

	isSpinner = false;
	objMetaField = [];
	handleMetaDataUpdate(){
		console.log('in handle upload field----');
		getObjFieldsMetadata({objectName : ['CSV_File_Upload_Field__mdt']})
		.then(result =>{
			this.metaDataField = result['CSV_File_Upload_Field__mdt'];
			this.metaDataField.forEach(meta =>{
				if(meta != 'id' && meta != 'developername' && meta != 'masterlabel' && meta != 'namespaceprefix' && meta != 'language' && meta != 'qualifiedapiname' && meta != 'label' && meta != 'sequence__c'){
					let metaDataApp = {};
					metaDataApp = meta;
					this.objMetaField.push(metaDataApp);
				}
			})
			var mapObjField = [];
			this.labelValue = this.csvApplicationLabel.replace(' ','_');
			this.TableData.forEach( data =>{
				console.log('data==>>',data.isSelected);
				let obj = {};
				this.objMetaField.forEach( field =>{
					console.log('=====',field);//csv_column_name__c
					obj[[field]] = data.field;
					if(!mapObjField.includes(obj) && (field === 'csv_file_upload_object__c')){
						console.log('in if');
						obj[[field]] = this.labelValue;
					}
					if(field === 'required__c'){
						obj[[field]] = data.isSelected;
						console.log('in if required--',obj[[field]]);
					}
				});
				mapObjField.push(obj);
				createUpdateMetadata({fullName :'CSV_File_Upload_Field__mdt.'+data.column, label : data.column, fieldVal : mapObjField})
				.then(result =>{
					if(result){
						//this.showSucessToastMetadata();
						//this.isSpinner = false;
						this.handleCloseModal();
						this.getLabel();
					}
					
				}).catch(error =>{
					console.log('error123--',error);
				})
			});
			console.log('mapObjField--1234',JSON.stringify(mapObjField));
		}).catch(error =>{
			console.log('error--',error);
		})
	}

	fieldsData = [];
	//fieldResult = false;
	objName = [];
	handleInput(event){
		console.log('in handle input--');
		this.objName = event.currentTarget.dataset.id;
		console.log('this.objName',this.objName);
		//this.dataTable = true;
		this.dropDownFields = true;
        this.isTypeList = true;
        this.dataTable = true;
		this.dropDownValues = false;
		//this.inputClass = 'slds-has-focus';
		this.fieldsData = [];
		console.log('fields--',JSON.stringify(this.fieldsData));
		this.TableData.forEach(el =>{
			el.isSelected = false;
		})
		for(let i = 0; i < 5; i++){
			this.fieldsData.push({label : this.objFields[i]});
			console.log('in for ',this.fieldsData);
		}
		console.log('fieldsData===',this.fieldsData);
		this.TableData.forEach(el =>{
			console.log('el--',el);
			if(el.column == this.objName){
				el.isSelected = true;
			}
		})
		console.log('fieldsData===',this.fieldsData);
		this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
	}
	
	isValueTable = false;
	selectedName;
	selectedLabel;
	onSelectValue(event){
		console.log('in onselect---');
		this.dropDownValues = false;
		let ele = event.currentTarget;
		this.selectedName = this.fieldAPIName[ele.dataset.name];
		this.selectedLabel = event.currentTarget.dataset.name;
		console.log('selectedLabel-',this.selectedLabel);

		console.log('selectedName==',this.selectedName);
		
		let selectedId = ele.dataset.id;
		console.log('selectedId=====',selectedId);
		this.TableData.forEach(d =>{
			if(d.column === selectedId){
				d.field = this.selectedName;
				d.isSelected = false;
				d.inputVal = this.selectedLabel;
			}
		});
		this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
	}
	
	onChange(event) {
        // this.searchField = event.target.value;  
		let searchVal = event.target.value;
		console.log('this.searchField==',searchVal);
		var ff = [];
		for(let i = 0; i < this.objFields.length; i++){
			if(this.objFields[i].startsWith(searchVal) == true && searchVal != ''){
				ff.push({label : this.objFields[i]});
			}
		}
		this.fieldsData = ff;
    }

	handleTodoChange(event) {  
			let col = event.currentTarget.dataset.id;
			console.log("TodoCheck: ",col);
			this.TableData.forEach(element =>{
				//console.log('element-',element);
				if(element.column == col){
					element.isSelected = event.target.checked;
					console.log('valueCheked--',element.isSelected);
				}
			})
	}

	blurTimeout;
	inblur(){
		console.log('inblue===');
		this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
	}

	isShowModalSpinner = false;
	isShowModalSpinnperFalse = false;
	getLabel(){
		getAppLabel({label : this.labelValue})
		.then(result =>{
			console.log('result ',result);
			if(result){
				this.isShowModalSpinner = true;
			}
			else{
				this.isShowModalSpinnperFalse = true;
			}
		}).catch(error =>{
			console.log('error--',error);
		})
	}	

	
	get options() {
		
        return this.fieldLookUp;
    }
	valueLookup ='';
    handleChangeLookUp(event) {
		console.log('value--',this.fieldLookUp);
        this.valueLookup = event.detail.value;
    }
}