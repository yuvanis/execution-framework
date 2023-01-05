/**
 * Created by Yury Nistratau on 01.01.2023.
 */

@IsTest
private class ActionExecutorTest {

    public with sharing class RequestCorrect extends Action {

        public override Type getType() {
            return RequestCorrect.class;
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

    public with sharing class RequestError extends Action {

        public override Type getType() {
            return RequestError.class;
        }

        public override void execute() {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.floatrates.com/daily/us.json');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                throw new ActionException('Exception');
            }
        }
    }

    @TestSetup
    static void setup() {
        ActionSettings__c actionSettings = new ActionSettings__c();
        RequestError requestError = new RequestError();
        actionSettings.Name = requestError.getType().getName();
        actionSettings.Interval__c = 1;
        actionSettings.Attempts__c = 3;
        insert actionSettings;
    }

    @IsTest
    static void testEmptyActionSettings() {
        ActionSettings__c emptyActionSettings = ActionSettings__c.getOrgDefaults();
        delete emptyActionSettings;
        new ActionScheduler(new RequestError()).schedule();
        ActionSettings__c newActionSettings = ActionSettings__c.getValues(new RequestError().getType().getName());
        System.assertEquals(3, newActionSettings.Attempts__c);
        System.assertEquals(1, newActionSettings.Interval__c);
    }

    @IsTest
    static void testActionExecutorPositive() {
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', 'Response', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ActionExecutor.execute(new RequestCorrect());
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob]);
    }

    @IsTest
    static void testActionExecutorNegative() {
        HTTPMockFactory mock = new HTTPMockFactory(404, 'Not found', 'Error', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RequestError requestError = new RequestError();
        ActionExecutor.execute(requestError);
        Test.stopTest();
        ActionSettings__c actionSettings = ActionSettings__c.getOrgDefaults();
        System.assertEquals(3, actionSettings.Attempts__c);
        System.assertEquals(1, actionSettings.Interval__c);
    }
}