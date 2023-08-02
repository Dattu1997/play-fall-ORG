public class apexInFlow {
       //@InvocableMethod (label='Get Account Name')  
        public static List<String> getAccountNames(List<Id> ids) {
            system.debug('method-->'+ ids);
          List<String> accountNames = new List<String>();
          List<Account> accounts = [SELECT Name FROM Account WHERE Id IN :ids];
          system.debug('Accounts --> '+ids);
          for (Account account : accounts) {
            accountNames.add(account.Name);
          }
          return accountNames;
        } 
 }