/**
 * Created by Yury Nistratau on 23.12.2022.
 */

public with sharing class ActionQueueable implements Queueable, Database.AllowsCallouts {
    public Action action;

    public ActionQueueable(Action action) {
        this.action = action;
    }

    public void execute(QueueableContext context) {
        ActionExecutor.execute(action);
    }
}