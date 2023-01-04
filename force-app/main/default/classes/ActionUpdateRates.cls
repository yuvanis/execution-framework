/**
 * Created by Yury Nistratau on 21.12.2022.
 */

public with sharing class ActionUpdateRates extends Action {

    public override Type getType() {
        return ActionUpdateRates.class;
    }

    public override void execute() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.floatrates.com/daily/usd.json');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            throw new ActionException('Exception');
        }
    }
}