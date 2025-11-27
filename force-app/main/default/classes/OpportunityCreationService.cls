/**
 * @description Service class for creating and managing Opportunities
 * @author CopadoAI
 * @date 2025-11-17
 */
public with sharing class OpportunityCreationService {
    
    /**
     * @description Creates a single Opportunity record
     * @param opportunityName Name of the opportunity
     * @param accountId Associated Account Id
     * @param amount Opportunity amount
     * @param closeDate Close date
     * @param stageName Stage name
     * @return Id of the created Opportunity
     */
    public static Id createOpportunity(String opportunityName, Id accountId, Decimal amount, 
                                       Date closeDate, String stageName) {
        if (String.isBlank(opportunityName)) {
            throw new OpportunityCreationException('Opportunity name cannot be blank');
        }
        
        if (accountId == null) {
            throw new OpportunityCreationException('Account Id cannot be null');
        }
        
        if (closeDate == null) {
            throw new OpportunityCreationException('Close date cannot be null');
        }
        
        if (String.isBlank(stageName)) {
            throw new OpportunityCreationException('Stage name cannot be blank');
        }
        
        Opportunity newOpp = new Opportunity(
            Name = opportunityName,
            AccountId = accountId,
            Amount = amount,
            CloseDate = closeDate,
            StageName = stageName
        );
        
        try {
            insert newOpp;
            return newOpp.Id;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to create opportunity: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates multiple Opportunity records in bulk
     * @param opportunityWrappers List of opportunity wrapper objects
     * @return List of created Opportunity Ids
     */
    public static List<Id> createOpportunities(List<OpportunityWrapper> opportunityWrappers) {
        if (opportunityWrappers == null || opportunityWrappers.isEmpty()) {
            throw new OpportunityCreationException('Opportunity list cannot be null or empty');
        }
        
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        
        for (OpportunityWrapper wrapper : opportunityWrappers) {
            validateOpportunityWrapper(wrapper);
            
            Opportunity opp = new Opportunity(
                Name = wrapper.opportunityName,
                AccountId = wrapper.accountId,
                Amount = wrapper.amount,
                CloseDate = wrapper.closeDate,
                StageName = wrapper.stageName,
                Probability = wrapper.probability,
                Type = wrapper.oppType,
                LeadSource = wrapper.leadSource,
                Description = wrapper.description
            );
            oppsToInsert.add(opp);
        }
        
        try {
            insert oppsToInsert;
            
            List<Id> oppIds = new List<Id>();
            for (Opportunity opp : oppsToInsert) {
                oppIds.add(opp.Id);
            }
            return oppIds;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to create opportunities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates Opportunities for multiple Accounts
     * @param accountIds Set of Account Ids
     * @param stageName Stage name for all opportunities
     * @param closeDate Close date for all opportunities
     * @return Map of Account Id to created Opportunity Id
     */
    public static Map<Id, Id> createOpportunitiesForAccounts(Set<Id> accountIds, String stageName, Date closeDate) {
        if (accountIds == null || accountIds.isEmpty()) {
            throw new OpportunityCreationException('Account Ids cannot be null or empty');
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
        
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        
        for (Id accountId : accountMap.keySet()) {
            Account acc = accountMap.get(accountId);
            Opportunity opp = new Opportunity(
                Name = acc.Name + ' - Opportunity',
                AccountId = accountId,
                StageName = stageName,
                CloseDate = closeDate
            );
            oppsToInsert.add(opp);
        }
        
        try {
            insert oppsToInsert;
            
            Map<Id, Id> accountToOppMap = new Map<Id, Id>();
            for (Opportunity opp : oppsToInsert) {
                accountToOppMap.put(opp.AccountId, opp.Id);
            }
            return accountToOppMap;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to create opportunities for accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates existing Opportunity records
     * @param opportunitiesToUpdate List of Opportunity records to update
     */
    public static void updateOpportunities(List<Opportunity> opportunitiesToUpdate) {
        if (opportunitiesToUpdate == null || opportunitiesToUpdate.isEmpty()) {
            return;
        }
        
        try {
            update opportunitiesToUpdate;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to update opportunities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates opportunity wrapper data
     * @param wrapper OpportunityWrapper to validate
     */
    private static void validateOpportunityWrapper(OpportunityWrapper wrapper) {
        if (String.isBlank(wrapper.opportunityName)) {
            throw new OpportunityCreationException('Opportunity name cannot be blank');
        }
        if (wrapper.accountId == null) {
            throw new OpportunityCreationException('Account Id cannot be null');
        }
        if (wrapper.closeDate == null) {
            throw new OpportunityCreationException('Close date cannot be null');
        }
        if (String.isBlank(wrapper.stageName)) {
            throw new OpportunityCreationException('Stage name cannot be blank');
        }
    }
    
    /**
     * @description Wrapper class for Opportunity creation
     */
    public class OpportunityWrapper {
        public String opportunityName { get; set; }
        public Id accountId { get; set; }
        public Decimal amount { get; set; }
        public Date closeDate { get; set; }
        public String stageName { get; set; }
        public Decimal probability { get; set; }
        public String oppType { get; set; }
        public String leadSource { get; set; }
        public String description { get; set; }
        
        public OpportunityWrapper(String opportunityName, Id accountId, Date closeDate, String stageName) {
            this.opportunityName = opportunityName;
            this.accountId = accountId;
            this.closeDate = closeDate;
            this.stageName = stageName;
        }
    }
    
    /**
     * @description Custom exception class for Opportunity creation errors
     */
    public class OpportunityCreationException extends Exception {}
}