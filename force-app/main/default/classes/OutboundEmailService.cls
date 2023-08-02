public class OutboundEmailService{ 
    public static void sendMassEmail(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] address = new string[]{'anumanlakadidathu@gmail.com'};
                mail.setToAddresses(address);
                mail.setSubject('Hi dattu Wish U Very Happy Birthday');
                mail.setPlainTextBody('Hi This is Dattu');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('Mail'+mail);
            // EmailUtility EU = new EmailUtility();
            // EU.processOutboundEmail(email);
}
}