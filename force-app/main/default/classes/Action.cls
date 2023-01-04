/**
 * Created by Yury Nistratau on 21.12.2022.
 */

public with sharing abstract class Action {
    public Integer counter = 0;

    public void incrementCounter() {
        counter++;
    }

    public abstract Type getType();
    public abstract void execute();
}