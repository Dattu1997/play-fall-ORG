public class QueueableDemo implements Queueable {
    public void execute(QueueableContext context) {
        Account acc = new Account(Name='Biswajeet');
        System.debug('acc '+acc);
        Insert acc;        
    }
}