public  class TaskObjectCreate {
    public static void getTaskData(Task details, String subject, String description, String type, String priority) {
        Task task = new Task();
        task.Subject = 'Call';
        task.Description = description;
        task.Type = type;
        task.Priority = priority;
        task.OwnerId = UserInfo.getUserId();
        task.ActivityDate = Date.today();

        Insert task;
    }
}