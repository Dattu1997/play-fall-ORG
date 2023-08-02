public class ContactModalPopUpController {
    @AuraEnabled
        public static Contact getContactSaved(String lastName, String email){
            System.debug('getContactSaved Method---- ');
            if(String.isNotBlank(lastName)){
                Contact con = new Contact(LastName = lastName, Email = email);
                try {
                    insert con;
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
                return con;
            }

            return null;
            
        }    
}