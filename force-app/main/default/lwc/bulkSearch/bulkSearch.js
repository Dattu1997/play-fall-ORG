import { api, LightningElement, track, wire } from 'lwc';
import accountSearch from '@salesforce/apex/BulkSearchController.accountSearch';
import getRequestToken from '@salesforce/apex/accessTokenWithConnectedApp.getRequestToken';
const columns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Phone', fieldName: 'Phone', type: 'Number'},
    {label: 'Description', fieldName: 'Description', type: 'text'},
    {label: 'Industry', fieldName: 'Industry', type: 'text'},
    {label: 'Website', fieldName: 'Website', type: 'url'}
];

export default class BulkSearch extends LightningElement {
    
    data = [];
    column = columns;
    showTable = false;
    d =[];
    handleButton(){
        this.showTable = true;
        let searchCmp = this.template.querySelector("lightning-textarea");
        // console.log('value: ',searchCmp.value);
        if(searchCmp.value && searchCmp.value !== ''){
            let searchTerms = searchCmp.value.split('\n');
            console.log('searches: ',searchTerms);
            var data = [];
            if(searchTerms.length <= 20){
                console.log('in if==');
                let ids=[];
                accountSearch({searchTerm : searchTerms})
                .then(result =>{
                    console.log('result--',result);
                    result.forEach(ele =>{
                        if(!ids.includes(ele.Id)){
                            ids.push(ele.Id);
                            this.d.push(ele);
                        }
                    })
                    // this.data = [...data];
                    // console.log('data--',this.data);
                }).catch(error =>{
                    console.error('columns error: ', error);
                })
            }else if(searchTerms.length > 20 && searchTerms.length < 40){
                let ids=[];
                console.log('else if--');
                accountSearch({searchTerm : searchTerms})
                .then(result =>{
                    console.log('result--',result);
                    let d =[];
                    result.forEach(ele =>{
                        if(!ids.includes(ele.Id)){
                            ids.push(ele.Id);
                            data.push(ele);
                        }
                    })
                    // this.data = [...data];
                    // console.log('data--',this.data);
                }).catch(error =>{
                    console.error('columns error: ', error);
                })
            }
            this.data = [...this.d];
            console.log('data--',this.data);
            let fetchedData = this.doFetch(searchTerms);
            
            let ids =[];
            let d =[];
            (async () => {
                let fetchedData = await this.doFetch(searchTerms);
                console.log('fetchedData--',fetchedData);
                fetchedData.forEach(element => {
                    console.log('element--',element);
                //     if(!ids.includes(ele.Id)){
                //                     ids.push(ele.Id);
                //                     d.push(ele);
                //                 }
                                
                            
                            
                });
                // this.data = [...d];
              })
            
        }else{
            searchCmp.reportValidity();
        }        
    }
    async doFetch(e){
        var accessToken;
        await getRequestToken()
        .then(result =>{
            console.log('res--',result);
            accessToken = result;
            
        }).catch(error =>{
            console.log('error- ',error);
        })
        var fetchResult;
        await fetch('https://playful-wolf-cz3uwx-dev-ed.my.salesforce.com/services/data/v56.0/search?q=FIND {'+e[0]+'} IN ALL FIELDS RETURNING Account(Id,Name,Phone,Description,Industry,Website)',{
        method: 'GET',
        headers:{Authorization :'Bearer '+accessToken}
        })
        .then(response=>response.json())
        .then(data=>{
            console.log('the dafta1111====',data.searchRecords);
            // let ids =[];
            // let d =[];
           fetchResult = data.searchRecords
           console.log('fetchResult--',fetchResult);
            //.foreach( ele =>{
        //         console.log('ele--',ele);
        //         if(!ids.includes(ele.Id)){
        //             ids.push(ele.Id);
        //             d.push(ele);
        //         }
                
        //     })
        //     this.data = [...d];
         })
         return fetchResult;
    }
    
}