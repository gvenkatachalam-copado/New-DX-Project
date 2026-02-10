/**
 * @description Handler class for Account tier management based on Annual Revenue
 * References custom field: Account_Tier__c
 * @author CopadoAI
 * @date 2026-02-10
 */
public with sharing class AccountTierHandler {
    
    // Constants for tier thresholds
    private static final Decimal PLATINUM_THRESHOLD = 1000000;
    private static final Decimal GOLD_THRESHOLD = 500000;
    private static final Decimal SILVER_THRESHOLD = 100000;
    
    /**
     * @description Updates Account_Tier__c based on AnnualRevenue
     * @param accountIds Set of Account IDs to process
     */
    public static void updateAccountTiers(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        
        // Query accounts with necessary fields
        List<Account> accountsToUpdate = [
            SELECT Id, AnnualRevenue, Account_Tier__c
            FROM Account
            WHERE Id IN :accountIds
            WITH SECURITY_ENFORCED
        ];
        
        List<Account> updatedAccounts = new List<Account>();
        
        for (Account acc : accountsToUpdate) {
            String newTier = calculateTier(acc.AnnualRevenue);
            
            // Only update if tier has changed
            if (acc.Account_Tier__c != newTier) {
                acc.Account_Tier__c = newTier;
                updatedAccounts.add(acc);
            }
        }
        
        if (!updatedAccounts.isEmpty()) {
            update updatedAccounts;
        }
    }
    
    /**
     * @description Calculates tier based on annual revenue
     * @param revenue Annual revenue amount
     * @return String tier value (Platinum, Gold, Silver, Bronze, or null)
     */
    public static String calculateTier(Decimal revenue) {
        if (revenue == null) {
            return null;
        }
        
        if (revenue >= PLATINUM_THRESHOLD) {
            return 'Platinum';
        } else if (revenue >= GOLD_THRESHOLD) {
            return 'Gold';
        } else if (revenue >= SILVER_THRESHOLD) {
            return 'Silver';
        } else {
            return 'Bronze';
        }
    }
    
    /**
     * @description Retrieves accounts by tier
     * @param tier Tier value to filter by
     * @return List of Accounts matching the tier
     */
    public static List<Account> getAccountsByTier(String tier) {
        if (String.isBlank(tier)) {
            return new List<Account>();
        }
        
        return [
            SELECT Id, Name, Account_Tier__c, AnnualRevenue
            FROM Account
            WHERE Account_Tier__c = :tier
            WITH SECURITY_ENFORCED
            ORDER BY AnnualRevenue DESC
            LIMIT 200
        ];
    }
    
    /**
     * @description Gets tier statistics
     * @return Map of tier to count
     */
    public static Map<String, Integer> getTierStatistics() {
        Map<String, Integer> tierStats = new Map<String, Integer>();
        
        AggregateResult[] results = [
            SELECT Account_Tier__c tier, COUNT(Id) cnt
            FROM Account
            WHERE Account_Tier__c != null
            WITH SECURITY_ENFORCED
            GROUP BY Account_Tier__c
        ];
        
        for (AggregateResult ar : results) {
            String tier = (String)ar.get('tier');
            Integer count = (Integer)ar.get('cnt');
            tierStats.put(tier, count);
        }
        
        return tierStats;
    }
}