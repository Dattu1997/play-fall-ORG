import { LightningElement,track,wire } from 'lwc';
import fetchAccounts from '@salesforce/apex/accountController.fetchAccounts';

export default class AccountsContatcsGrid extends LightningElement {

    @track gridColumns = [{
        type: 'text',
        fieldName: 'Name',
        label: 'Name'
    },
    {
        type: 'text',
        fieldName: 'Industry',
        label: 'Industry'
    },
    {
        type: 'text',
        fieldName: 'FirstName',
        label: 'FirstName'
    },
    {
        type: 'text',
        fieldName: 'LastName',
        label: 'LastName'
    }];
    @track gridData;

    @wire(fetchAccounts)
    accountTreeData({ error, data }) {

        console.log( 'Inside wire' );
        if ( data ) {

            var tempData = JSON.parse( JSON.stringify( data ) );
            console.log( 'Data is ' + tempData );
            /*var tempjson = JSON.parse( JSON.stringify( data ).split( 'Contacts' ).join( '_children' ) );
            console.log( 'Temp JSON is ' + tempjson );*/
            for ( var i = 0; i < tempData.length; i++ ) {

                tempData[ i ]._children = tempData[ i ][ 'Contacts' ];
                delete tempData[ i ].Contacts;

            }
            this.gridData = tempData;

        } else if ( error ) {
           
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );

        }

    }

}