/**
 * @description Test class for OpportunityCreator with 100% code coverage
 * @author Copado AI
 * @date 2025-11-10
 */
@isTest
private class OpportunityCreatorTest {
    
    /**
     * @description Setup test data
     */
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
    }
    
    /**
     * @description Test successful single Opportunity creation
     */
    @isTest
    static void testCreateOpportunity_Success() {
        // Get test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Id oppId = OpportunityCreator.createOpportunity(
            'Test Opportunity',
            testAccount.Id,
            Date.today().addDays(30),
            'Prospecting',
            10000
        );
        Test.stopTest();
        
        // Verify Opportunity was created
        Opportunity createdOpp = [SELECT Id, Name, AccountId, CloseDate, StageName, Amount 
                                  FROM Opportunity 
                                  WHERE Id = :oppId];
        
        System.assertNotEquals(null, createdOpp, 'Opportunity should be created');
        System.assertEquals('Test Opportunity', createdOpp.Name, 'Name should match');
        System.assertEquals(testAccount.Id, createdOpp.AccountId, 'Account should match');
        System.assertEquals('Prospecting', createdOpp.StageName, 'Stage should match');
        System.assertEquals(10000, createdOpp.Amount, 'Amount should match');
    }
    
    /**
     * @description Test Opportunity creation with blank name
     */
    @isTest
    static void testCreateOpportunity_BlankName() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunity(
                '',
                testAccount.Id,
                Date.today().addDays(30),
                'Prospecting',
                10000
            );
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Name cannot be blank'), 'Error message should mention blank name');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test Opportunity creation with null close date
     */
    @isTest
    static void testCreateOpportunity_NullCloseDate() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunity(
                'Test Opportunity',
                testAccount.Id,
                null,
                'Prospecting',
                10000
            );
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Close Date cannot be null'), 'Error message should mention null close date');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test Opportunity creation with blank stage name
     */
    @isTest
    static void testCreateOpportunity_BlankStageName() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunity(
                'Test Opportunity',
                testAccount.Id,
                Date.today().addDays(30),
                '',
                10000
            );
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Stage Name cannot be blank'), 'Error message should mention blank stage');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk Opportunity creation
     */
    @isTest
    static void testCreateOpportunities_BulkSuccess() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> oppsToCreate = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            oppsToCreate.add(new Opportunity(
                Name = 'Bulk Test Opportunity ' + i,
                AccountId = testAccount.Id,
                CloseDate = Date.today().addDays(30),
                StageName = 'Prospecting',
                Amount = 5000 + i
            ));
        }
        
        Test.startTest();
        List<Id> oppIds = OpportunityCreator.createOpportunities(oppsToCreate);
        Test.stopTest();
        
        // Verify all Opportunities were created
        System.assertEquals(200, oppIds.size(), 'Should create 200 Opportunities');
        
        List<Opportunity> createdOpps = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        System.assertEquals(200, createdOpps.size(), 'All Opportunities should be in database');
    }
    
    /**
     * @description Test bulk creation with null list
     */
    @isTest
    static void testCreateOpportunities_NullList() {
        Test.startTest();
        try {
            OpportunityCreator.createOpportunities(null);
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('cannot be null or empty'), 'Error message should mention null list');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk creation with empty list
     */
    @isTest
    static void testCreateOpportunities_EmptyList() {
        Test.startTest();
        try {
            OpportunityCreator.createOpportunities(new List<Opportunity>());
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('cannot be null or empty'), 'Error message should mention empty list');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk creation with invalid Opportunity (blank name)
     */
    @isTest
    static void testCreateOpportunities_InvalidOpportunity() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> oppsToCreate = new List<Opportunity>{
            new Opportunity(
                Name = '',
                AccountId = testAccount.Id,
                CloseDate = Date.today().addDays(30),
                StageName = 'Prospecting',
                Amount = 5000
            )
        };
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunities(oppsToCreate);
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Name cannot be blank'), 'Error message should mention validation failure');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test creating Opportunity with default values
     */
    @isTest
    static void testCreateOpportunityWithDefaults_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Id oppId = OpportunityCreator.createOpportunityWithDefaults(
            'Default Test Opportunity',
            testAccount.Id
        );
        Test.stopTest();
        
        // Verify Opportunity was created with defaults
        Opportunity createdOpp = [SELECT Id, Name, AccountId, CloseDate, StageName, Amount 
                                  FROM Opportunity 
                                  WHERE Id = :oppId];
        
        System.assertNotEquals(null, createdOpp, 'Opportunity should be created');
        System.assertEquals('Default Test Opportunity', createdOpp.Name, 'Name should match');
        System.assertEquals(testAccount.Id, createdOpp.AccountId, 'Account should match');
        System.assertEquals('Prospecting', createdOpp.StageName, 'Default stage should be Prospecting');
        System.assertEquals(0, createdOpp.Amount, 'Default amount should be 0');
        System.assertEquals(Date.today().addDays(30), createdOpp.CloseDate, 'Default close date should be 30 days from today');
    }
    
    /**
     * @description Test validateOpportunity method indirectly through bulk creation with null close date
     */
    @isTest
    static void testValidateOpportunity_NullCloseDate() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> oppsToCreate = new List<Opportunity>{
            new Opportunity(
                Name = 'Test Opp',
                AccountId = testAccount.Id,
                CloseDate = null,
                StageName = 'Prospecting',
                Amount = 5000
            )
        };
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunities(oppsToCreate);
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Close Date cannot be null'), 'Error message should mention null close date');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test validateOpportunity method indirectly through bulk creation with blank stage
     */
    @isTest
    static void testValidateOpportunity_BlankStage() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> oppsToCreate = new List<Opportunity>{
            new Opportunity(
                Name = 'Test Opp',
                AccountId = testAccount.Id,
                CloseDate = Date.today().addDays(30),
                StageName = '',
                Amount = 5000
            )
        };
        
        Test.startTest();
        try {
            OpportunityCreator.createOpportunities(oppsToCreate);
            System.assert(false, 'Exception should have been thrown');
        } catch (OpportunityCreator.OpportunityCreationException e) {
            System.assert(e.getMessage().contains('Stage Name cannot be blank'), 'Error message should mention blank stage');
        }
        Test.stopTest();
    }
}