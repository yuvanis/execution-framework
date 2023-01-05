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
            actionSettings = (ActionSettings__c) new ActionSettings__c();
            actionSettings.Name = action.getType().getName();
            actionSettings.Attempts__c = 3;
            actionSettings.Interval__c = 1;
            insert actionSettings;
        }
    }

    private String buildCronExpression() {
        return Datetime.now().addMinutes(actionSettings.Interval__c.intValue()).format('ss mm HH d M ? yyyy');
    }

    private static String getCurrentTime() {
        return Datetime.now().format('MMM d, HH:mm:ss:SSS');
    }

    public void schedule() {
        ActionScheduler actionScheduler = new ActionScheduler(action);
        if (action.counter <= actionSettings.Attempts__c) {
            System.schedule('Action name: ' + action.getType().getName() + '. Time: ' + getCurrentTime(), buildCronExpression(), actionScheduler);
        }
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new ActionQueueable(action));
    }
}