/**
 * @description Test class for AccountCreationService
 * @author CopadoAI
 * @date 2025-11-26
 */
@IsTest
private class AccountCreationServiceTest_v2 {
    
    /**
     * @description Test successful single account creation
     */
    @IsTest
    static void testCreateAccount_Success() {
        // Arrange
        String accountName = 'Test Account';
        String industry = 'Technology';
        Decimal annualRevenue = 1000000;
        
        // Act
        Test.startTest();
        Id accountId = AccountCreationService.createAccount(accountName, industry, annualRevenue);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, accountId, 'Account Id should not be null');
        
        Account createdAccount = [SELECT Id, Name, Industry, AnnualRevenue 
                                   FROM Account 
                                   WHERE Id = :accountId];
        System.assertEquals(accountName, createdAccount.Name, 'Account name should match');
        System.assertEquals(industry, createdAccount.Industry, 'Industry should match');
        System.assertEquals(annualRevenue, createdAccount.AnnualRevenue, 'Annual revenue should match');
    }
    
    /**
     * @description Test account creation with blank name throws exception
     */
    @IsTest
    static void testCreateAccount_BlankName() {
        // Arrange
        String accountName = '';
        String industry = 'Technology';
        Decimal annualRevenue = 1000000;
        
        // Act & Assert
        Test.startTest();
        try {
            AccountCreationService.createAccount(accountName, industry, annualRevenue);
            System.assert(false, 'Expected AccountCreationException was not thrown');
        } catch (AccountCreationService.AccountCreationException e) {
            System.assert(e.getMessage().contains('Account name cannot be blank'), 
                         'Exception message should indicate blank name');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk account creation with multiple records
     */
    @IsTest
    static void testCreateAccounts_BulkSuccess() {
        // Arrange
        List<AccountCreationService.AccountWrapper> wrappers = new List<AccountCreationService.AccountWrapper>();
        
        for (Integer i = 0; i < 200; i++) {
            AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper(
                'Test Account ' + i,
                'Technology',
                1000000 + (i * 10000)
            );
            wrapper.phone = '555-000-' + String.valueOf(i).leftPad(4, '0');
            wrapper.billingCity = 'San Francisco';
            wrapper.billingState = 'CA';
            wrapper.billingCountry = 'USA';
            wrappers.add(wrapper);
        }
        
        // Act
        Test.startTest();
        List<Id> accountIds = AccountCreationService.createAccounts(wrappers);
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, accountIds.size(), 'Should create 200 accounts');
        
        List<Account> createdAccounts = [SELECT Id, Name, Industry, Phone, BillingCity 
                                          FROM Account 
                                          WHERE Id IN :accountIds];
        System.assertEquals(200, createdAccounts.size(), 'Should retrieve 200 accounts');
        System.assertEquals('San Francisco', createdAccounts[0].BillingCity, 'Billing city should match');
    }
    
    /**
     * @description Test bulk account creation with null list
     */
    @IsTest
    static void testCreateAccounts_NullList() {
        // Act & Assert
        Test.startTest();
        try {
            AccountCreationService.createAccounts(null);
            System.assert(false, 'Expected AccountCreationException was not thrown');
        } catch (AccountCreationService.AccountCreationException e) {
            System.assert(e.getMessage().contains('cannot be null or empty'), 
                         'Exception message should indicate null list');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk account creation with empty list
     */
    @IsTest
    static void testCreateAccounts_EmptyList() {
        // Act & Assert
        Test.startTest();
        try {
            AccountCreationService.createAccounts(new List<AccountCreationService.AccountWrapper>());
            System.assert(false, 'Expected AccountCreationException was not thrown');
        } catch (AccountCreationService.AccountCreationException e) {
            System.assert(e.getMessage().contains('cannot be null or empty'), 
                         'Exception message should indicate empty list');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk account creation with blank account name in wrapper
     */
    @IsTest
    static void testCreateAccounts_BlankNameInWrapper() {
        // Arrange
        List<AccountCreationService.AccountWrapper> wrappers = new List<AccountCreationService.AccountWrapper>();
        AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper(
            '',
            'Technology',
            1000000
        );
        wrappers.add(wrapper);
        
        // Act & Assert
        Test.startTest();
        try {
            AccountCreationService.createAccounts(wrappers);
            System.assert(false, 'Expected AccountCreationException was not thrown');
        } catch (AccountCreationService.AccountCreationException e) {
            System.assert(e.getMessage().contains('Account name cannot be blank'), 
                         'Exception message should indicate blank name');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test update accounts successfully
     */
    @IsTest
    static void testUpdateAccounts_Success() {
        // Arrange - Create test accounts first
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            testAccounts.add(new Account(
                Name = 'Original Name ' + i,
                Industry = 'Technology'
            ));
        }
        insert testAccounts;
        
        // Modify the accounts
        for (Account acc : testAccounts) {
            acc.Industry = 'Finance';
            acc.AnnualRevenue = 5000000;
        }
        
        // Act
        Test.startTest();
        AccountCreationService.updateAccounts(testAccounts);
        Test.stopTest();
        
        // Assert
        List<Account> updatedAccounts = [SELECT Id, Industry, AnnualRevenue 
                                          FROM Account 
                                          WHERE Id IN :testAccounts];
        for (Account acc : updatedAccounts) {
            System.assertEquals('Finance', acc.Industry, 'Industry should be updated');
            System.assertEquals(5000000, acc.AnnualRevenue, 'Annual revenue should be updated');
        }
    }
    
    /**
     * @description Test update accounts with null list (should return gracefully)
     */
    @IsTest
    static void testUpdateAccounts_NullList() {
        // Act
        Test.startTest();
        AccountCreationService.updateAccounts(null);
        Test.stopTest();
        
        // Assert - No exception should be thrown
        System.assert(true, 'Method should handle null list gracefully');
    }
    
    /**
     * @description Test update accounts with empty list (should return gracefully)
     */
    @IsTest
    static void testUpdateAccounts_EmptyList() {
        // Act
        Test.startTest();
        AccountCreationService.updateAccounts(new List<Account>());
        Test.stopTest();
        
        // Assert - No exception should be thrown
        System.assert(true, 'Method should handle empty list gracefully');
    }
    
    /**
     * @description Test AccountWrapper constructor
     */
    @IsTest
    static void testAccountWrapper_Constructor() {
        // Act
        Test.startTest();
        AccountCreationService.AccountWrapper wrapper = new AccountCreationService.AccountWrapper(
            'Test Account',
            'Healthcare',
            2500000
        );
        Test.stopTest();
        
        // Assert
        System.assertEquals('Test Account', wrapper.accountName, 'Account name should match');
        System.assertEquals('Healthcare', wrapper.industry, 'Industry should match');
        System.assertEquals(2500000, wrapper.annualRevenue, 'Annual revenue should match');
        System.assertEquals(null, wrapper.phone, 'Phone should be null');
        System.assertEquals(null, wrapper.billingCity, 'Billing city should be null');
    }
}