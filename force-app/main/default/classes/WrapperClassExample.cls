public  class WrapperClassExample {
    public void callwrapper(){
        List<wrapperclass> lst=new List<wrapperclass>();
       contact cnn=[select id,LastName from contact limit 1];
        for(Account acc_new:[select id,name from Account]){
          wrapperclass obj=new wrapperclass(acc_new);
          lst.add(obj);
        }
           
           
           wrapperclass obj1=new wrapperclass(cnn);
           lst.add(obj1);
           system.debug(lst.size());
      }

      public class wrapperclass{
        @AuraEnabled
            public string name;
            public wrapperclass(Account dattuAnumandla){
                name=dattuAnumandla.name; 
                system.debug('sdfhrs' + name);

            }
            public wrapperclass(contact dattu){
                name=dattu.LastName;
                system.debug('lhjj' + name);    
            }
           
        }  
    }