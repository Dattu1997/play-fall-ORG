public class AccountHandler {
    public static Account insertNewAccount(string a) {
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Employer Company').getRecordTypeId();
       
        try{
            Account acc = new Account();
            acc.Name = a;
            acc.recordTypeId = recordType;
            acc.Description = 'New Employer Company';
            acc.Type = 'Prospect';
            insert acc;
            System.debug('account name' + acc);
            return acc;
            
            
           
        }
        catch (DmlException e) {
            System.debug('A DML exception has occurred: ' +
                        e.getMessage());
            return null;            
        }
           
        
    }
}