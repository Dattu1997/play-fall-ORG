public class AccountAddressTriggerHandler {
    public static void beforeInsert(List<Account> accList) {
        System.debug('accList'+accList);
        //List<Account> newAccList = new List<Account>();
     for(Account acc : accList){
       System.debug('acc.Match_Billing_Address__c ' +acc.Match_Billing_Address__c); 
         if(acc.Match_Billing_Address__c ==true){
             acc.ShippingPostalCode = acc.BillingPostalCode;
             //newAccList.add(acc);
         }
     }
     //insert newAccList;
    
    }
    public static void beforeUpdate(List<Account> accList){
        for(Account acc : accList){

            if(acc.Match_Billing_Address__c ==true){
                acc.ShippingPostalCode = acc.BillingPostalCode;
            }
        }

    }
}