public class TaskController {
    @AuraEnabled(cacheable=true)
    public static void getTaskData(Task details, String subject, String description, String type, String priority) {
        System.debug('In line ===3');
        Task task = new Task();
        task.Subject = 'Call';
        task.Description = description;
        task.Type = type;
        task.Priority = priority;
        task.OwnerId = UserInfo.getUserId();
        task.ActivityDate = Date.today();
        System.debug('task==='+task);
        Insert task;
    }
}