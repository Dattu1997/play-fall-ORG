public class displayContact {
public List<Contact> getMyContacts() {
  return [SELECT Id, Name,Phone,Email, Account.Name,Title FROM Contact where Phone != null AND Title!=null AND Account.Name !=null];
  }
}