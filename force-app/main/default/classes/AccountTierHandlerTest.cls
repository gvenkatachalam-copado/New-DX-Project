/**
 * @description Test class for AccountTierHandler
 * @author CopadoAI
 * @date 2026-02-10
 */
@IsTest
private class AccountTierHandlerTest {
    
    /**
     * @description Test data factory method
     */
    @TestSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        
        // Platinum tier accounts
        testAccounts.add(new Account(
            Name = 'Platinum Account 1',
            AnnualRevenue = 1500000
        ));
        testAccounts.add(new Account(
            Name = 'Platinum Account 2',
            AnnualRevenue = 2000000
        ));
        
        // Gold tier accounts
        testAccounts.add(new Account(
            Name = 'Gold Account 1',
            AnnualRevenue = 750000
        ));
        testAccounts.add(new Account(
            Name = 'Gold Account 2',
            AnnualRevenue = 600000
        ));
        
        // Silver tier accounts
        testAccounts.add(new Account(
            Name = 'Silver Account 1',
            AnnualRevenue = 250000
        ));
        testAccounts.add(new Account(
            Name = 'Silver Account 2',
            AnnualRevenue = 150000
        ));
        
        // Bronze tier accounts
        testAccounts.add(new Account(
            Name = 'Bronze Account 1',
            AnnualRevenue = 50000
        ));
        testAccounts.add(new Account(
            Name = 'Bronze Account 2',
            AnnualRevenue = 25000
        ));
        
        // Account with null revenue
        testAccounts.add(new Account(
            Name = 'No Revenue Account',
            AnnualRevenue = null
        ));
        
        insert testAccounts;
    }
    
    /**
     * @description Test updateAccountTiers method with valid data
     */
    @IsTest
    static void testUpdateAccountTiers_Success() {
        // Query test accounts
        List<Account> accounts = [SELECT Id FROM Account WHERE AnnualRevenue != null];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        AccountTierHandler.updateAccountTiers(accountIds);
        Test.stopTest();
        
        // Verify tiers were set correctly
        List<Account> updatedAccounts = [
            SELECT Name, AnnualRevenue, Account_Tier__c
            FROM Account
            WHERE Id IN :accountIds
            ORDER BY AnnualRevenue DESC
        ];
        
        for (Account acc : updatedAccounts) {
            if (acc.AnnualRevenue >= 1000000) {
                System.assertEquals('Platinum', acc.Account_Tier__c, 
                    'Account with revenue >= 1M should be Platinum');
            } else if (acc.AnnualRevenue >= 500000) {
                System.assertEquals('Gold', acc.Account_Tier__c, 
                    'Account with revenue >= 500K should be Gold');
            } else if (acc.AnnualRevenue >= 100000) {
                System.assertEquals('Silver', acc.Account_Tier__c, 
                    'Account with revenue >= 100K should be Silver');
            } else {
                System.assertEquals('Bronze', acc.Account_Tier__c, 
                    'Account with revenue < 100K should be Bronze');
            }
        }
    }
    
    /**
     * @description Test updateAccountTiers with null/empty input
     */
    @IsTest
    static void testUpdateAccountTiers_NullInput() {
        Test.startTest();
        AccountTierHandler.updateAccountTiers(null);
        AccountTierHandler.updateAccountTiers(new Set<Id>());
        Test.stopTest();
        
        // No exception should be thrown
        System.assert(true, 'Method should handle null/empty input gracefully');
    }
    
    /**
     * @description Test calculateTier method with various revenue amounts
     */
    @IsTest
    static void testCalculateTier_AllTiers() {
        Test.startTest();
        
        // Test Platinum
        String platinumTier = AccountTierHandler.calculateTier(1500000);
        System.assertEquals('Platinum', platinumTier, 'Should return Platinum for 1.5M');
        
        // Test Gold
        String goldTier = AccountTierHandler.calculateTier(750000);
        System.assertEquals('Gold', goldTier, 'Should return Gold for 750K');
        
        // Test Silver
        String silverTier = AccountTierHandler.calculateTier(250000);
        System.assertEquals('Silver', silverTier, 'Should return Silver for 250K');
        
        // Test Bronze
        String bronzeTier = AccountTierHandler.calculateTier(50000);
        System.assertEquals('Bronze', bronzeTier, 'Should return Bronze for 50K');
        
        // Test null revenue
        String nullTier = AccountTierHandler.calculateTier(null);
        System.assertEquals(null, nullTier, 'Should return null for null revenue');
        
        // Test boundary values
        System.assertEquals('Platinum', AccountTierHandler.calculateTier(1000000), 
            'Exactly 1M should be Platinum');
        System.assertEquals('Gold', AccountTierHandler.calculateTier(500000), 
            'Exactly 500K should be Gold');
        System.assertEquals('Silver', AccountTierHandler.calculateTier(100000), 
            'Exactly 100K should be Silver');
        System.assertEquals('Bronze', AccountTierHandler.calculateTier(99999), 
            'Just under 100K should be Bronze');
        
        Test.stopTest();
    }
    
    /**
     * @description Test getAccountsByTier method
     */
    @IsTest
    static void testGetAccountsByTier_Success() {
        // First update tiers
        List<Account> accounts = [SELECT Id FROM Account WHERE AnnualRevenue != null];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        AccountTierHandler.updateAccountTiers(accountIds);
        
        Test.startTest();
        
        // Test retrieving Platinum accounts
        List<Account> platinumAccounts = AccountTierHandler.getAccountsByTier('Platinum');
        System.assertEquals(2, platinumAccounts.size(), 'Should return 2 Platinum accounts');
        
        // Test retrieving Gold accounts
        List<Account> goldAccounts = AccountTierHandler.getAccountsByTier('Gold');
        System.assertEquals(2, goldAccounts.size(), 'Should return 2 Gold accounts');
        
        // Test retrieving Silver accounts
        List<Account> silverAccounts = AccountTierHandler.getAccountsByTier('Silver');
        System.assertEquals(2, silverAccounts.size(), 'Should return 2 Silver accounts');
        
        // Test retrieving Bronze accounts
        List<Account> bronzeAccounts = AccountTierHandler.getAccountsByTier('Bronze');
        System.assertEquals(2, bronzeAccounts.size(), 'Should return 2 Bronze accounts');
        
        // Verify ordering (highest revenue first)
        System.assert(platinumAccounts[0].AnnualRevenue >= platinumAccounts[1].AnnualRevenue,
            'Accounts should be ordered by revenue descending');
        
        Test.stopTest();
    }
    
    /**
     * @description Test getAccountsByTier with invalid input
     */
    @IsTest
    static void testGetAccountsByTier_InvalidInput() {
        Test.startTest();
        
        List<Account> emptyResult = AccountTierHandler.getAccountsByTier('');
        System.assertEquals(0, emptyResult.size(), 'Should return empty list for blank tier');
        
        List<Account> nullResult = AccountTierHandler.getAccountsByTier(null);
        System.assertEquals(0, nullResult.size(), 'Should return empty list for null tier');
        
        List<Account> invalidResult = AccountTierHandler.getAccountsByTier('InvalidTier');
        System.assertEquals(0, invalidResult.size(), 'Should return empty list for invalid tier');
        
        Test.stopTest();
    }
    
    /**
     * @description Test getTierStatistics method
     */
    @IsTest
    static void testGetTierStatistics_Success() {
        // First update tiers
        List<Account> accounts = [SELECT Id FROM Account WHERE AnnualRevenue != null];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        AccountTierHandler.updateAccountTiers(accountIds);
        
        Test.startTest();
        Map<String, Integer> stats = AccountTierHandler.getTierStatistics();
        Test.stopTest();
        
        // Verify statistics
        System.assertEquals(2, stats.get('Platinum'), 'Should have 2 Platinum accounts');
        System.assertEquals(2, stats.get('Gold'), 'Should have 2 Gold accounts');
        System.assertEquals(2, stats.get('Silver'), 'Should have 2 Silver accounts');
        System.assertEquals(2, stats.get('Bronze'), 'Should have 2 Bronze accounts');
        System.assertEquals(4, stats.size(), 'Should have 4 tier categories');
    }
    
    /**
     * @description Test bulk processing (governor limit awareness)
     */
    @IsTest
    static void testUpdateAccountTiers_BulkProcessing() {
        // Create additional accounts for bulk testing
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 150; i++) {
            bulkAccounts.add(new Account(
                Name = 'Bulk Account ' + i,
                AnnualRevenue = Math.random() * 2000000
            ));
        }
        insert bulkAccounts;
        
        Set<Id> bulkIds = new Set<Id>();
        for (Account acc : bulkAccounts) {
            bulkIds.add(acc.Id);
        }
        
        Test.startTest();
        AccountTierHandler.updateAccountTiers(bulkIds);
        Test.stopTest();
        
        // Verify all accounts were processed
        List<Account> processedAccounts = [
            SELECT Id, Account_Tier__c
            FROM Account
            WHERE Id IN :bulkIds AND Account_Tier__c != null
        ];
        
        System.assertEquals(150, processedAccounts.size(), 
            'All 150 accounts should have tiers assigned');
    }
    
    /**
     * @description Test tier update only when changed
     */
    @IsTest
    static void testUpdateAccountTiers_NoChangeScenario() {
        List<Account> accounts = [SELECT Id FROM Account WHERE AnnualRevenue != null LIMIT 1];
        Set<Id> accountIds = new Set<Id>{accounts[0].Id};
        
        // First update
        AccountTierHandler.updateAccountTiers(accountIds);
        
        Account acc = [SELECT Account_Tier__c FROM Account WHERE Id = :accounts[0].Id];
        String originalTier = acc.Account_Tier__c;
        
        Test.startTest();
        // Second update with no revenue change
        AccountTierHandler.updateAccountTiers(accountIds);
        Test.stopTest();
        
        Account updatedAcc = [SELECT Account_Tier__c FROM Account WHERE Id = :accounts[0].Id];
        System.assertEquals(originalTier, updatedAcc.Account_Tier__c, 
            'Tier should remain unchanged');
    }
}