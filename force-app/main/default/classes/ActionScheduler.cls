/**
 * Created by Yury Nistratau on 21.12.2022.
 */

public with sharing class ActionScheduler implements Schedulable {
    public Action action;
    public ActionSettings__c actionSettings;

    public ActionScheduler(Action action) {
        this.action = action;
        actionSettings = ActionSettings__c.getValues(action.getType().getName());
        if (actionSettings == null) {
            actionSettings.Name = action.getType().getName();
            actionSettings.Attempts__c = 3;
            actionSettings.Interval__c = 1;
            insert actionSettings;
        }
    }

    private String buildCronExpression() {
        return System.now().second() + ' ' + (System.now().minute() +
                actionSettings.Interval__c.intValue()) + ' ' + System.now().hour() + ' '
                + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year();
    }

    public void schedule() {
        ActionScheduler actionScheduler = new ActionScheduler(action);
        if (action.counter <= actionSettings.Attempts__c) {
            System.schedule(action.getType().getName() + System.now().getTime(), buildCronExpression(), actionScheduler);
        }
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new ActionQueueable(action));
    }
}