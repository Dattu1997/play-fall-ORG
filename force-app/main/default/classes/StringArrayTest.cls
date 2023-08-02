public class StringArrayTest {
    public static list<string> generateStringArray(Integer a) {
        list<string> str = new list<string>();
        for(Integer i=0; i<a; i++){
            str.add('Test '+i);
         
            
        }
        System.debug('list of string'+ str);

        return str;
        



    }
}