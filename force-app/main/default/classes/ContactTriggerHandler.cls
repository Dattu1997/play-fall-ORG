public class ContactTriggerHandler 
{

    public static void beforeInsert(List<Contact> conList) 
    {
        checkContactDetails(conList);
    }

    public static void beforeDelete(List<Contact> conList){
        checkContactDelete(conList);
    }

    public static void checkContactDetails(List<Contact> conList){
        for(Contact con: conList){
            System.debug(con.Description);
            if(con.Title == null){
                con.Title = 'The contact title is SALESFORCE DEVELOPER';
                System.debug('Title'+con.Title);
            }
            if(con.Email == null){
                con.Email = con.LastName+con.FirstName +'@gmail.com';
                System.debug('con'+con.Email);
            }
        }
    }

    public static void checkContactDelete(List<Contact> conList){

        for(Contact con : conList){
            if(con.AccountId != null){
                con.addError('Unable to delete contacts which are related to Account');
            }
        }
    }

}