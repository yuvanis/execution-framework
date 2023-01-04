/**
 * Created by Yury Nistratau on 21.12.2022.
 */

public with sharing class ActionExecutor {

    public static void execute(Action action) {
        try {
            action.execute();
        } catch (ActionException e) {
            action.incrementCounter();
            new ActionScheduler(action).schedule();
        }
    }
}