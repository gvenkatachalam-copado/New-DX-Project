@IsTest
private class ProjectRequestDemoServiceTest {

    @TestSetup
    static void setupData() {
        List<Project_Request_Demo__c> requests = new List<Project_Request_Demo__c>();
        for (Integer i = 0; i < 3; i++) {
            requests.add(new Project_Request_Demo__c(
                Name = 'Open Request ' + i,
                Status__c = 'New'
            ));
        }
        requests.add(new Project_Request_Demo__c(
            Name = 'Rejected Request',
            Status__c = 'Rejected'
        ));
        insert requests;
    }

    @IsTest
    static void getMaxOpenRequestsReturnsPositiveValue() {
        Test.startTest();
        Integer maxOpen = ProjectRequestDemoService.getMaxOpenRequests();
        Test.stopTest();

        System.assert(maxOpen > 0, 'Max open requests should be a positive number.');
    }

    @IsTest
    static void getStatusMessageReturnsExpectedLabels() {
        Test.startTest();
        String approved = ProjectRequestDemoService.getStatusMessage('Approved');
        String rejected = ProjectRequestDemoService.getStatusMessage('Rejected');
        String other = ProjectRequestDemoService.getStatusMessage('New');
        Test.stopTest();

        System.assertEquals(Label.PR_Demo_Approved_Message, approved);
        System.assertEquals(Label.PR_Demo_Rejected_Message, rejected);
        System.assertEquals('', other);
    }

    @IsTest
    static void isLimitReachedHandlesAllCases() {
        System.assertEquals(true, ProjectRequestDemoService.isLimitReached(10, 10));
        System.assertEquals(true, ProjectRequestDemoService.isLimitReached(11, 10));
        System.assertEquals(false, ProjectRequestDemoService.isLimitReached(9, 10));
        System.assertEquals(false, ProjectRequestDemoService.isLimitReached(null, 10));
        System.assertEquals(false, ProjectRequestDemoService.isLimitReached(5, null));
    }

    @IsTest
    static void hasReachedOpenLimitCountsOnlyOpenRequests() {
        Test.startTest();
        Boolean reached = ProjectRequestDemoService.hasReachedOpenLimit(UserInfo.getUserId());
        Test.stopTest();

        Integer openCount = [
            SELECT COUNT()
            FROM Project_Request_Demo__c
            WHERE OwnerId = :UserInfo.getUserId()
            AND Status__c IN ('New', 'In Review')
        ];
        System.assertEquals(
            openCount >= ProjectRequestDemoService.getMaxOpenRequests(),
            reached,
            'Result should match the open request count against the configured limit.'
        );
    }
}