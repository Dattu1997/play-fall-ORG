public class ContactSearch {
    public static List<contact> searchForContacts(string a, string postal) {
        
        list<Contact> con = [SELECT Id, lastName, MailingPostalCode FROM Contact WHERE lastName = :a and MailingPostalCode =:postal];
        return con;
    }
    
}