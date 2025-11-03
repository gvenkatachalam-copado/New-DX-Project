/**
 * @description Test class for ContactController
 * @author CopadoAI
 */
@IsTest
private class ContactControllerTest {
    
    /**
     * @description Setup test data
     */
    @TestSetup
    static void setupTestData() {
        List<Contact> testContacts = new List<Contact>();
        
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com',
                Phone = '555-000-000' + i
            ));
        }
        
        insert testContacts;
    }
    
    /**
     * @description Test getAllContacts method - positive scenario
     */
    @IsTest
    static void testGetAllContacts_Success() {
        Test.startTest();
        List<Contact> contacts = ContactController.getAllContacts();
        Test.stopTest();
        
        System.assertEquals(5, contacts.size(), 'Should return 5 contacts');
        System.assertNotEquals(null, contacts[0].Id, 'Contact should have an Id');
    }
    
    /**
     * @description Test getContactById method - positive scenario
     */
    @IsTest
    static void testGetContactById_Success() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Contact retrievedContact = ContactController.getContactById(testContact.Id);
        Test.stopTest();
        
        System.assertEquals(testContact.Id, retrievedContact.Id, 'Should return the correct contact');
        System.assertNotEquals(null, retrievedContact.LastName, 'Contact should have a last name');
    }
    
    /**
     * @description Test getContactById method - null Id
     */
    @IsTest
    static void testGetContactById_NullId() {
        Test.startTest();
        try {
            ContactController.getContactById(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should throw IllegalArgumentException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getContactById method - contact not found
     */
    @IsTest
    static void testGetContactById_NotFound() {
        // Create a fake Id that doesn't exist
        Id fakeId = '003000000000000AAA';
        
        Test.startTest();
        try {
            ContactController.getContactById(fakeId);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('not found'), 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test createContact method - positive scenario
     */
    @IsTest
    static void testCreateContact_Success() {
        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'TestContact',
            Email = 'newtest@example.com'
        );
        
        Test.startTest();
        Id contactId = ContactController.createContact(newContact);
        Test.stopTest();
        
        System.assertNotEquals(null, contactId, 'Should return a contact Id');
        
        Contact createdContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId];
        System.assertEquals('New', createdContact.FirstName, 'First name should match');
        System.assertEquals('TestContact', createdContact.LastName, 'Last name should match');
    }
    
    /**
     * @description Test createContact method - null contact
     */
    @IsTest
    static void testCreateContact_NullContact() {
        Test.startTest();
        try {
            ContactController.createContact(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should throw IllegalArgumentException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateContact method - positive scenario
     */
    @IsTest
    static void testUpdateContact_Success() {
        Contact testContact = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        testContact.FirstName = 'Updated';
        testContact.LastName = 'Name';
        
        Test.startTest();
        ContactController.updateContact(testContact);
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('Updated', updatedContact.FirstName, 'First name should be updated');
        System.assertEquals('Name', updatedContact.LastName, 'Last name should be updated');
    }
    
    /**
     * @description Test updateContact method - null contact
     */
    @IsTest
    static void testUpdateContact_NullContact() {
        Test.startTest();
        try {
            ContactController.updateContact(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should throw IllegalArgumentException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateContact method - null Id
     */
    @IsTest
    static void testUpdateContact_NullId() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        
        Test.startTest();
        try {
            ContactController.updateContact(testContact);
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should throw IllegalArgumentException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test deleteContact method - positive scenario
     */
    @IsTest
    static void testDeleteContact_Success() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Id contactId = testContact.Id;
        
        Test.startTest();
        ContactController.deleteContact(contactId);
        Test.stopTest();
        
        List<Contact> deletedContacts = [SELECT Id FROM Contact WHERE Id = :contactId];
        System.assertEquals(0, deletedContacts.size(), 'Contact should be deleted');
    }
    
    /**
     * @description Test deleteContact method - null Id
     */
    @IsTest
    static void testDeleteContact_NullId() {
        Test.startTest();
        try {
            ContactController.deleteContact(null);
            System.assert(false, 'Should have thrown an exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should throw IllegalArgumentException');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test searchContactsByLastName method - positive scenario
     */
    @IsTest
    static void testSearchContactsByLastName_Success() {
        Test.startTest();
        List<Contact> contacts = ContactController.searchContactsByLastName('Contact');
        Test.stopTest();
        
        System.assertEquals(5, contacts.size(), 'Should find all 5 contacts');
    }
    
    /**
     * @description Test searchContactsByLastName method - partial match
     */
    @IsTest
    static void testSearchContactsByLastName_PartialMatch() {
        Test.startTest();
        List<Contact> contacts = ContactController.searchContactsByLastName('Contact1');
        Test.stopTest();
        
        System.assertEquals(1, contacts.size(), 'Should find 1 contact');
        System.assert(contacts[0].LastName.contains('Contact1'), 'Should match the search pattern');
    }
    
    /**
     * @description Test searchContactsByLastName method - blank search
     */
    @IsTest
    static void testSearchContactsByLastName_BlankSearch() {
        Test.startTest();
        List<Contact> contacts = ContactController.searchContactsByLastName('');
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'Should return empty list for blank search');
    }
    
    /**
     * @description Test searchContactsByLastName method - null search
     */
    @IsTest
    static void testSearchContactsByLastName_NullSearch() {
        Test.startTest();
        List<Contact> contacts = ContactController.searchContactsByLastName(null);
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'Should return empty list for null search');
    }
    
    /**
     * @description Test searchContactsByLastName method - no results
     */
    @IsTest
    static void testSearchContactsByLastName_NoResults() {
        Test.startTest();
        List<Contact> contacts = ContactController.searchContactsByLastName('NonExistent');
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'Should return empty list when no matches found');
    }
}