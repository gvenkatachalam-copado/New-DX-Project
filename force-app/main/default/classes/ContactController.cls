/**
 * @description Controller class for Contact operations
 * @author CopadoAI
 */
public with sharing class ContactController {
    
    /**
     * @description Retrieves all contacts
     * @return List of Contact records
     */
    public static List<Contact> getAllContacts() {
        try {
            return [
                SELECT Id, FirstName, LastName, Email, Phone, AccountId
                FROM Contact
                ORDER BY LastName
                LIMIT 1000
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving contacts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves a contact by Id
     * @param contactId The Id of the contact to retrieve
     * @return Contact record
     */
    public static Contact getContactById(Id contactId) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact Id cannot be null');
        }
        
        try {
            List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Email, Phone, AccountId
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
            
            if (contacts.isEmpty()) {
                throw new AuraHandledException('Contact not found');
            }
            
            return contacts[0];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates a new contact
     * @param newContact The contact to create
     * @return Id of the created contact
     */
    public static Id createContact(Contact newContact) {
        if (newContact == null) {
            throw new IllegalArgumentException('Contact cannot be null');
        }
        
        try {
            insert newContact;
            return newContact.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating contact: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates an existing contact
     * @param contactToUpdate The contact to update
     */
    public static void updateContact(Contact contactToUpdate) {
        if (contactToUpdate == null || contactToUpdate.Id == null) {
            throw new IllegalArgumentException('Contact and Contact Id cannot be null');
        }
        
        try {
            update contactToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating contact: ' + e.getMessage());
        }
    }
    
    /**
     * @description Deletes a contact by Id
     * @param contactId The Id of the contact to delete
     */
    public static void deleteContact(Id contactId) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact Id cannot be null');
        }
        
        try {
            Contact contactToDelete = new Contact(Id = contactId);
            delete contactToDelete;
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting contact: ' + e.getMessage());
        }
    }
    
    /**
     * @description Searches contacts by last name
     * @param lastName The last name to search for
     * @return List of matching contacts
     */
    public static List<Contact> searchContactsByLastName(String lastName) {
        if (String.isBlank(lastName)) {
            return new List<Contact>();
        }
        
        try {
            String searchPattern = '%' + lastName + '%';
            return [
                SELECT Id, FirstName, LastName, Email, Phone
                FROM Contact
                WHERE LastName LIKE :searchPattern
                ORDER BY LastName
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error searching contacts: ' + e.getMessage());
        }
    }
}