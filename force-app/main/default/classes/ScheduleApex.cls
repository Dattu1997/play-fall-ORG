public  class ScheduleApex implements Schedulable {
    public void execute(SchedulableContext sc) {

        AccountBatchApex obj = new AccountBatchApex();
        database.executeBatch(obj);
      

    }
}