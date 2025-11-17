/**
 * @description Service class for creating and managing Accounts
 * @author CopadoAI
 * @date 2025-11-17
 */
public with sharing class AccountCreationService {
    
    /**
     * @description Creates a single Account record
     * @param accountName Name of the account to create
     * @param industry Industry of the account
     * @param annualRevenue Annual revenue of the account
     * @return Id of the created Account
     */
    public static Id createAccount(String accountName, String industry, Decimal annualRevenue) {
        if (String.isBlank(accountName)) {
            throw new AccountCreationException('Account name cannot be blank');
        }
        
        Account newAccount = new Account(
            Name = accountName,
            Industry = industry,
            AnnualRevenue = annualRevenue
        );
        
        try {
            insert newAccount;
            return newAccount.Id;
        } catch (DmlException e) {
            throw new AccountCreationException('Failed to create account: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates multiple Account records in bulk
     * @param accountWrappers List of account wrapper objects containing account details
     * @return List of created Account Ids
     */
    public static List<Id> createAccounts(List<AccountWrapper> accountWrappers) {
        if (accountWrappers == null || accountWrappers.isEmpty()) {
            throw new AccountCreationException('Account list cannot be null or empty');
        }
        
        List<Account> accountsToInsert = new List<Account>();
        
        for (AccountWrapper wrapper : accountWrappers) {
            if (String.isBlank(wrapper.accountName)) {
                throw new AccountCreationException('Account name cannot be blank');
            }
            
            Account acc = new Account(
                Name = wrapper.accountName,
                Industry = wrapper.industry,
                AnnualRevenue = wrapper.annualRevenue,
                Phone = wrapper.phone,
                BillingCity = wrapper.billingCity,
                BillingState = wrapper.billingState,
                BillingCountry = wrapper.billingCountry
            );
            accountsToInsert.add(acc);
        }
        
        try {
            insert accountsToInsert;
            
            List<Id> accountIds = new List<Id>();
            for (Account acc : accountsToInsert) {
                accountIds.add(acc.Id);
            }
            return accountIds;
        } catch (DmlException e) {
            throw new AccountCreationException('Failed to create accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates existing Account records
     * @param accountsToUpdate List of Account records to update
     */
    public static void updateAccounts(List<Account> accountsToUpdate) {
        if (accountsToUpdate == null || accountsToUpdate.isEmpty()) {
            return;
        }
        
        try {
            update accountsToUpdate;
        } catch (DmlException e) {
            throw new AccountCreationException('Failed to update accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Wrapper class for Account creation
     */
    public class AccountWrapper {
        public String accountName { get; set; }
        public String industry { get; set; }
        public Decimal annualRevenue { get; set; }
        public String phone { get; set; }
        public String billingCity { get; set; }
        public String billingState { get; set; }
        public String billingCountry { get; set; }
        
        public AccountWrapper(String accountName, String industry, Decimal annualRevenue) {
            this.accountName = accountName;
            this.industry = industry;
            this.annualRevenue = annualRevenue;
        }
    }
    
    /**
     * @description Custom exception class for Account creation errors
     */
    public class AccountCreationException extends Exception {}
}