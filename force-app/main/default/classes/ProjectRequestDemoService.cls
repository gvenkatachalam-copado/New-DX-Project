/**
 * Service class for the Project Request Demo object.
 * Reads limits from custom metadata and messages from custom labels.
 */
public with sharing class ProjectRequestDemoService {

    private static final Integer DEFAULT_MAX_OPEN_REQUESTS = 10;
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_REJECTED = 'Rejected';

    /**
     * Returns the configured maximum number of open requests per owner.
     * Falls back to a default when the setting is missing.
     */
    public static Integer getMaxOpenRequests() {
        Project_Request_Demo_Setting__mdt setting =
            Project_Request_Demo_Setting__mdt.getInstance('Default');
        if (setting != null && setting.Max_Open_Requests__c != null) {
            return Integer.valueOf(setting.Max_Open_Requests__c);
        }
        return DEFAULT_MAX_OPEN_REQUESTS;
    }

    /**
     * Returns the user facing message for a status, or an empty string.
     */
    public static String getStatusMessage(String status) {
        if (status == STATUS_APPROVED) {
            return Label.PR_Demo_Approved_Message;
        }
        if (status == STATUS_REJECTED) {
            return Label.PR_Demo_Rejected_Message;
        }
        return '';
    }

    /**
     * Pure comparison helper, easy to unit test.
     */
    public static Boolean isLimitReached(Integer openCount, Integer maxOpen) {
        if (openCount == null || maxOpen == null) {
            return false;
        }
        return openCount >= maxOpen;
    }

    /**
     * Checks whether an owner has reached the open request limit.
     */
    public static Boolean hasReachedOpenLimit(Id ownerId) {
        Integer openCount = [
            SELECT COUNT()
            FROM Project_Request_Demo__c
            WHERE OwnerId = :ownerId
            AND Status__c IN ('New', 'In Review')
        ];
        return isLimitReached(openCount, getMaxOpenRequests());
    }
}