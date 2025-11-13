/**
 * @description Handler class for creating Opportunity records with proper error handling
 * @author Copado AI
 * @date 2025-11-10
 */
public with sharing class OpportunityCreator {
    
    /**
     * @description Creates a single Opportunity record
     * @param oppName Name of the Opportunity
     * @param accountId Related Account Id
     * @param closeDate Close Date for the Opportunity
     * @param stageName Stage Name for the Opportunity
     * @param amount Opportunity Amount
     * @return Id of the created Opportunity
     * @throws OpportunityCreationException if creation fails
     */
    public static Id createOpportunity(String oppName, Id accountId, Date closeDate, String stageName, Decimal amount) {
        if (String.isBlank(oppName)) {
            throw new OpportunityCreationException('Opportunity Name cannot be blank');
        }
        
        if (closeDate == null) {
            throw new OpportunityCreationException('Close Date cannot be null');
        }
        
        if (String.isBlank(stageName)) {
            throw new OpportunityCreationException('Stage Name cannot be blank');
        }
        
        Opportunity opp = new Opportunity(
            Name = oppName,
            AccountId = accountId,
            CloseDate = closeDate,
            StageName = stageName,
            Amount = amount
        );
        
        try {
            insert opp;
            return opp.Id;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to create Opportunity: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates multiple Opportunity records in bulk
     * @param opportunities List of Opportunities to create
     * @return List of created Opportunity Ids
     * @throws OpportunityCreationException if bulk creation fails
     */
    public static List<Id> createOpportunities(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.isEmpty()) {
            throw new OpportunityCreationException('Opportunity list cannot be null or empty');
        }
        
        // Validate all opportunities before insertion
        for (Opportunity opp : opportunities) {
            validateOpportunity(opp);
        }
        
        try {
            insert opportunities;
            List<Id> oppIds = new List<Id>();
            for (Opportunity opp : opportunities) {
                oppIds.add(opp.Id);
            }
            return oppIds;
        } catch (DmlException e) {
            throw new OpportunityCreationException('Failed to create Opportunities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates an Opportunity with default values
     * @param oppName Name of the Opportunity
     * @param accountId Related Account Id
     * @return Id of the created Opportunity
     */
    public static Id createOpportunityWithDefaults(String oppName, Id accountId) {
        return createOpportunity(
            oppName,
            accountId,
            Date.today().addDays(30),
            'Prospecting',
            0
        );
    }
    
    /**
     * @description Validates an Opportunity record before insertion
     * @param opp Opportunity to validate
     * @throws OpportunityCreationException if validation fails
     */
    private static void validateOpportunity(Opportunity opp) {
        if (String.isBlank(opp.Name)) {
            throw new OpportunityCreationException('Opportunity Name cannot be blank');
        }
        
        if (opp.CloseDate == null) {
            throw new OpportunityCreationException('Close Date cannot be null');
        }
        
        if (String.isBlank(opp.StageName)) {
            throw new OpportunityCreationException('Stage Name cannot be blank');
        }
    }
    
    /**
     * @description Custom exception class for Opportunity creation errors
     */
    public class OpportunityCreationException extends Exception {}
}