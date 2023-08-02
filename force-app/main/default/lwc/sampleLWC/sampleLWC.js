import { LightningElement,wire } from 'lwc';
import getAccounts from '@salesforce/apex/accountController.getAccounts';
export default class SampleLWC extends LightningElement {
    records;
    sortedColumn;
    sortedDirection = 'asc';
    initialRecords;

    @wire( getAccounts )  
    wiredAccount( { error, data } ) {
        if (data) {
            this.records = data;
            this.initialRecords = data;
            this.error = undefined;

        } else if ( error ) {

            this.error = error;
            this.initialRecords = undefined;
            this.records = undefined;

        }
    }  

    sortRecs( event ) {

        let colName = event.target.name;
        console.log( 'Column Name is ' + colName );
        if ( this.sortedColumn === colName ) {
            this.sortedDirection = ( this.sortedDirection === 'asc' ? 'desc' : 'asc' );
        }
        else {
            this.sortedDirection = 'asc';
        }

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = colName;

        // sort the data
        this.records = JSON.parse( JSON.stringify( this.records ) ).sort( ( a, b ) => {
            a = a[ colName ] ? a[ colName ].toLowerCase() : '';

            b = b[ colName ] ? b[ colName ].toLowerCase() : '';
            return a > b ? 1 * isReverse : -1 * isReverse;
        });;
    }

    handleKeyChange( event ) {  
          
        const searchKey = event.target.value.toLowerCase();  
        console.log( 'Search Key is ' + searchKey );
 
        if ( searchKey ) {  

            this.records = this.initialRecords;
 
             if ( this.records ) {

                let recs = [];
                for ( let rec of this.records ) {

                    console.log( 'Rec is ' + JSON.stringify( rec ) );
                    let valuesArray = Object.values( rec );
                    console.log( 'valuesArray is ' + valuesArray );
 
                    for ( let val of valuesArray ) {
                        
                        if ( val ) {

                            if ( val.toLowerCase().includes( searchKey ) ) {

                                recs.push( rec );
                                break;
                        
                            }

                        }

                    }
                    
                }

                console.log( 'Recs are ' + JSON.stringify( recs ) );
                this.records = recs;

             }
 
        }  else {

            this.records = this.initialRecords;

        }
 
    }  

}