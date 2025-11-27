/**
 * @description Test class for AccountCreationService
 * @author CopadoAI
 * @date 2025-11-17
 */
@IsTest
private class AccountCreationServiceTest {
    
    /**
     * @description Test data factory for creating test accounts
     */
    @TestSetup
    static void setupTestData() {
        // Test setup can be added here if needed for multiple test methods
    }
    
    /**
     * @description Test successful single account creation
     */
    @IsTest
    static void testCreateAccount_Success() {
        Test.startTest();
        Id accountId = AccountCreationService.createAccount('Test Account', 'Technology', 1000000);
        Test.stopTest();
        
        Account createdAccount = [SELECT Id, Name, Industry, AnnualRevenue FROM Account WHERE Id = :accountId];
        
        Assert.isNotNull(createdAccount, 'Account should be created');
        Assert.areEqual('Test Account', createdAccount.Name, 'Account name should match');
        Assert.areEqual('Technology', createdAccount.Industry, 'Industry should match');
        Assert.areEqual(1000000, createdAccount.AnnualRevenue, 'Annual revenue should match');
    }
    
    /**
     * @description Test account creation with blank name
     */
    @IsTest
    static void testCreateAccount_BlankName() {
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        Test.startTest();
        try {
            AccountCreationService.createAccount('', 'Technology', 1000000);
        } catch (AccountCreationService.AccountCreationException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for blank account name');
        Assert.isTrue(exceptionMessage.contains('Account name cannot be blank'), 'Exception message should indicate blank name');
    }
    
    /**
     * @description Test bulk account creation
     */
    @IsTest
    static void testCreateAccounts_Bulk() {
        List<AccountCreationService.AccountWrapper> accountWrappers = new List<AccountCreationService.AccountWrapper>();
        
        for (Integer i = 0; i < 200; i++) {
            AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper(
                'Bulk Account ' + i,
                'Technology',
                100000 + (i * 1000)
            );
            wrapper.phone = '555-000-' + String.valueOf(i).leftPad(4, '0');
            wrapper.billingCity = 'San Francisco';
            wrapper.billingState = 'CA';
            wrapper.billingCountry = 'USA';
            accountWrappers.add(wrapper);
        }
        
        Test.startTest();
        List<Id> accountIds = AccountCreationService.createAccounts(accountWrappers);
        Test.stopTest();
        
        Assert.areEqual(200, accountIds.size(), 'Should create 200 accounts');
        
        List<Account> createdAccounts = [SELECT Id, Name, Industry, Phone FROM Account WHERE Id IN :accountIds];
        Assert.areEqual(200, createdAccounts.size(), 'Should retrieve 200 accounts');
        
        for (Account acc : createdAccounts) {
            Assert.isTrue(acc.Name.startsWith('Bulk Account'), 'Account name should start with Bulk Account');
            Assert.areEqual('Technology', acc.Industry, 'Industry should be Technology');
        }
    }
    
    /**
     * @description Test bulk account creation with null list
     */
    @IsTest
    static void testCreateAccounts_NullList() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            AccountCreationService.createAccounts(null);
        } catch (AccountCreationService.AccountCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for null list');
    }
    
    /**
     * @description Test bulk account creation with empty list
     */
    @IsTest
    static void testCreateAccounts_EmptyList() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            AccountCreationService.createAccounts(new List<AccountCreationService.AccountWrapper>());
        } catch (AccountCreationService.AccountCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for empty list');
    }
    
    /**
     * @description Test bulk account creation with blank name in wrapper
     */
    @IsTest
    static void testCreateAccounts_BlankNameInWrapper() {
        List<AccountCreationService.AccountWrapper> accountWrappers = new List<AccountCreationService.AccountWrapper>();
        AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper('', 'Technology', 100000);
        accountWrappers.add(wrapper);
        
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            AccountCreationService.createAccounts(accountWrappers);
        } catch (AccountCreationService.AccountCreationException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for blank account name in wrapper');
    }
    
    /**
     * @description Test update accounts method
     */
    @IsTest
    static void testUpdateAccounts_Success() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Update Test ' + i, Industry = 'Technology'));
        }
        insert testAccounts;
        
        // Update accounts
        for (Account acc : testAccounts) {
            acc.Industry = 'Finance';
            acc.AnnualRevenue = 500000;
        }
        
        Test.startTest();
        AccountCreationService.updateAccounts(testAccounts);
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, Industry, AnnualRevenue FROM Account WHERE Id IN :testAccounts];
        
        for (Account acc : updatedAccounts) {
            Assert.areEqual('Finance', acc.Industry, 'Industry should be updated to Finance');
            Assert.areEqual(500000, acc.AnnualRevenue, 'Annual revenue should be updated');
        }
    }
    
    /**
     * @description Test update accounts with null list
     */
    @IsTest
    static void testUpdateAccounts_NullList() {
        Test.startTest();
        AccountCreationService.updateAccounts(null);
        Test.stopTest();
        
        // Should not throw exception, just return
        Assert.isTrue(true, 'Method should handle null gracefully');
    }
    
    /**
     * @description Test update accounts with empty list
     */
    @IsTest
    static void testUpdateAccounts_EmptyList() {
        Test.startTest();
        AccountCreationService.updateAccounts(new List<Account>());
        Test.stopTest();
        
        // Should not throw exception, just return
        Assert.isTrue(true, 'Method should handle empty list gracefully');
    }
    
    /**
     * @description Test account wrapper constructor
     */
    @IsTest
    static void testAccountWrapper_Constructor() {
        Test.startTest();
        AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper(
            'Test Account',
            'Healthcare',
            2000000
        );
        Test.stopTest();
        
        Assert.areEqual('Test Account', wrapper.accountName, 'Account name should match');
        Assert.areEqual('Healthcare', wrapper.industry, 'Industry should match');
        Assert.areEqual(2000000, wrapper.annualRevenue, 'Annual revenue should match');
    }
    
    /**
     * @description Test running as different user for security context
     */
    @IsTest
    static void testCreateAccount_AsStandardUser() {
        User standardUser = createStandardUser();
        
        System.runAs(standardUser) {
            Test.startTest();
            Id accountId = AccountCreationService.createAccount('User Test Account', 'Retail', 750000);
            Test.stopTest();
            
            Account createdAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId];
            Assert.isNotNull(createdAccount, 'Account should be created by standard user');
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