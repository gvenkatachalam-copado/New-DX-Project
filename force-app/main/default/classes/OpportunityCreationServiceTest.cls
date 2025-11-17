/**
 * @description Test class for OpportunityCreationService
 * @author CopadoAI
 * @date 2025-11-17
 */
@IsTest
private class OpportunityCreationServiceTest {
    
    /**
     * @description Test data factory for creating test accounts
     */
    @TestSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i, Industry = 'Technology'));
        }
        insert testAccounts;
    }
    
    /**
     * @description Test successful single opportunity creation
     */
    @IsTest
    static void testCreateOpportunity_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Id oppId = OpportunityCreationService.createOpportunity(
            'Test Opportunity',
            testAccount.Id,
            50000,
            Date.today().addDays(30),
            'Prospecting'
        );
        Test.stopTest();
        
        Opportunity createdOpp = [SELECT Id, Name, AccountId, Amount, CloseDate, StageName 
                                  FROM Opportunity WHERE Id = :oppId];
        
        Assert.isNotNull(createdOpp, 'Opportunity should be created');
        Assert.areEqual('Test Opportunity', createdOpp.Name, 'Opportunity name should match');
        Assert.areEqual(testAccount.Id, createdOpp.AccountId, 'Account Id should match');
        Assert.areEqual(50000, createdOpp.Amount, 'Amount should match');
        Assert.areEqual('Prospecting', createdOpp.StageName, 'Stage should match');
    }
    
    /**
     * @description Test opportunity creation with blank name
     */
    @IsTest
    static void testCreateOpportunity_BlankName() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunity(
                '',
                testAccount.Id,
                50000,
                Date.today().addDays(30),
                'Prospecting'
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for blank opportunity name');
    }
    
    /**
     * @description Test opportunity creation with null account
     */
    @IsTest
    static void testCreateOpportunity_NullAccount() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunity(
                'Test Opp',
                null,
                50000,
                Date.today().addDays(30),
                'Prospecting'
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for null account');
    }
    
    /**
     * @description Test opportunity creation with null close date
     */
    @IsTest
    static void testCreateOpportunity_NullCloseDate() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunity(
                'Test Opp',
                testAccount.Id,
                50000,
                null,
                'Prospecting'
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for null close date');
    }
    
    /**
     * @description Test opportunity creation with blank stage
     */
    @IsTest
    static void testCreateOpportunity_BlankStage() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunity(
                'Test Opp',
                testAccount.Id,
                50000,
                Date.today().addDays(30),
                ''
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for blank stage');
    }
    
    /**
     * @description Test bulk opportunity creation
     */
    @IsTest
    static void testCreateOpportunities_Bulk() {
        List<Account> testAccounts = [SELECT Id FROM Account];
        List<OpportunityCreationService.OpportunityWrapper> oppWrappers = 
            new List<OpportunityCreationService.OpportunityWrapper>();
        
        for (Integer i = 0; i < 200; i++) {
            Account acc = testAccounts[Math.mod(i, testAccounts.size())];
            OpportunityCreationService.OpportunityWrapper wrapper = 
                new OpportunityCreationService.OpportunityWrapper(
                    'Bulk Opp ' + i,
                    acc.Id,
                    Date.today().addDays(30 + i),
                    'Prospecting'
                );
            wrapper.amount = 10000 + (i * 100);
            wrapper.probability = 10;
            wrapper.oppType = 'New Business';
            wrapper.leadSource = 'Web';
            wrapper.description = 'Test opportunity ' + i;
            oppWrappers.add(wrapper);
        }
        
        Test.startTest();
        List<Id> oppIds = OpportunityCreationService.createOpportunities(oppWrappers);
        Test.stopTest();
        
        Assert.areEqual(200, oppIds.size(), 'Should create 200 opportunities');
        
        List<Opportunity> createdOpps = [SELECT Id, Name, Amount, Type, LeadSource 
                                         FROM Opportunity WHERE Id IN :oppIds];
        Assert.areEqual(200, createdOpps.size(), 'Should retrieve 200 opportunities');
        
        for (Opportunity opp : createdOpps) {
            Assert.isTrue(opp.Name.startsWith('Bulk Opp'), 'Opportunity name should start with Bulk Opp');
            Assert.areEqual('New Business', opp.Type, 'Type should be New Business');
            Assert.areEqual('Web', opp.LeadSource, 'Lead source should be Web');
        }
    }
    
    /**
     * @description Test bulk opportunity creation with null list
     */
    @IsTest
    static void testCreateOpportunities_NullList() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunities(null);
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for null list');
    }
    
    /**
     * @description Test bulk opportunity creation with empty list
     */
    @IsTest
    static void testCreateOpportunities_EmptyList() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunities(
                new List<OpportunityCreationService.OpportunityWrapper>()
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for empty list');
    }
    
    /**
     * @description Test creating opportunities for multiple accounts
     */
    @IsTest
    static void testCreateOpportunitiesForAccounts_Success() {
        List<Account> testAccounts = [SELECT Id FROM Account];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        Map<Id, Id> accountToOppMap = OpportunityCreationService.createOpportunitiesForAccounts(
            accountIds,
            'Qualification',
            Date.today().addDays(60)
        );
        Test.stopTest();
        
        Assert.areEqual(testAccounts.size(), accountToOppMap.size(), 
                       'Should create one opportunity per account');
        
        List<Opportunity> createdOpps = [SELECT Id, AccountId, StageName, CloseDate 
                                         FROM Opportunity WHERE Id IN :accountToOppMap.values()];
        
        for (Opportunity opp : createdOpps) {
            Assert.areEqual('Qualification', opp.StageName, 'Stage should be Qualification');
            Assert.areEqual(Date.today().addDays(60), opp.CloseDate, 'Close date should match');
            Assert.isTrue(accountToOppMap.containsKey(opp.AccountId), 
                         'Map should contain account Id');
        }
    }
    
    /**
     * @description Test creating opportunities for accounts with null set
     */
    @IsTest
    static void testCreateOpportunitiesForAccounts_NullSet() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunitiesForAccounts(
                null,
                'Qualification',
                Date.today().addDays(60)
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for null account set');
    }
    
    /**
     * @description Test creating opportunities for accounts with empty set
     */
    @IsTest
    static void testCreateOpportunitiesForAccounts_EmptySet() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            OpportunityCreationService.createOpportunitiesForAccounts(
                new Set<Id>(),
                'Qualification',
                Date.today().addDays(60)
            );
        } catch (OpportunityCreationService.OpportunityCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for empty account set');
    }
    
    /**
     * @description Test update opportunities method
     */
    @IsTest
    static void testUpdateOpportunities_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Opportunity> testOpps = new List<Opportunity>();
        
        for (Integer i = 0; i < 5; i++) {
            testOpps.add(new Opportunity(
                Name = 'Update Test ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert testOpps;
        
        for (Opportunity opp : testOpps) {
            opp.StageName = 'Closed Won';
            opp.Amount = 100000;
        }
        
        Test.startTest();
        OpportunityCreationService.updateOpportunities(testOpps);
        Test.stopTest();
        
        List<Opportunity> updatedOpps = [SELECT Id, StageName, Amount 
                                         FROM Opportunity WHERE Id IN :testOpps];
        
        for (Opportunity opp : updatedOpps) {
            Assert.areEqual('Closed Won', opp.StageName, 'Stage should be updated to Closed Won');
            Assert.areEqual(100000, opp.Amount, 'Amount should be updated');
        }
    }
    
    /**
     * @description Test update opportunities with null list
     */
    @IsTest
    static void testUpdateOpportunities_NullList() {
        Test.startTest();
        OpportunityCreationService.updateOpportunities(null);
        Test.stopTest();
        
        Assert.isTrue(true, 'Method should handle null gracefully');
    }
    
    /**
     * @description Test opportunity wrapper constructor
     */
    @IsTest
    static void testOpportunityWrapper_Constructor() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        OpportunityCreationService.OpportunityWrapper wrapper = 
            new OpportunityCreationService.OpportunityWrapper(
                'Test Wrapper Opp',
                testAccount.Id,
                Date.today().addDays(45),
                'Negotiation'
            );
        Test.stopTest();
        
        Assert.areEqual('Test Wrapper Opp', wrapper.opportunityName, 'Name should match');
        Assert.areEqual(testAccount.Id, wrapper.accountId, 'Account Id should match');
        Assert.areEqual('Negotiation', wrapper.stageName, 'Stage should match');
    }
    
    /**
     * @description Test running as different user for security context
     */
    @IsTest
    static void testCreateOpportunity_AsStandardUser() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User standardUser = createStandardUser();
        
        System.runAs(standardUser) {
            Test.startTest();
            Id oppId = OpportunityCreationService.createOpportunity(
                'User Test Opp',
                testAccount.Id,
                75000,
                Date.today().addDays(30),
                'Prospecting'
            );
            Test.stopTest();
            
            Opportunity createdOpp = [SELECT Id, Name FROM Opportunity WHERE Id = :oppId];
            Assert.isNotNull(createdOpp, 'Opportunity should be created by standard user');
        }
    }
    
    /**
     * @description Helper method to create a standard user for testing
     */
    private static User createStandardUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        return testUser;
    }
}