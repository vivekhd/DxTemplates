@isTest
private inherited sharing class CanTheUser_Tests {

    @isTest
    static void canCrudAccountCreatePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.CREATE),
            'Unless scratch org defaults have been changed by the user, this test should pass - asserting that users can create accounts'
        );
    }

    @isTest
    static void canCrudCreateAccountPositive() {
        System.assert(
            CanTheUser.create(new Account()),
            'Unless scratch org defaults have been changed by the user, this test should pass - asserting that users can create accounts'
        );
    }
    
    @isTest
    static void canCrudCreateDocumentPositive() {
        System.assertEquals(true, CanTheUser.create('Document__c'), 'Assertion failed: CanTheUser.create(\'Document__c\') should return true');

    }
    
    @isTest
    static void canCrudCreateDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
         System.assertEquals(true, CanTheUser.create(listDoc), 'Assertion failed: CanTheUser.create(listDoc) should return true');

    }
    
    @isTest
    static void canCrudReadDocumentPositive() {
      
        System.assertEquals(true, CanTheUser.read('Document__c'), 'Assertion failed: CanTheUser.read(\'Document__c\') should return true');

    }
    
   	@isTest
    static void canCrudEditDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
         System.assertEquals(true, CanTheUser.edit(listDoc), 'Assertion failed: CanTheUser.edit(listDoc) should return true');

    }
    
    @isTest
    static void canCrudEditDocumentPositive() {
        System.assertEquals(true, CanTheUser.edit('Document__c'), 'Assertion failed: CanTheUser.edit(\'Document__c\') should return true');

        
    }
    
    @isTest
    static void canCrudUpsDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
         System.assertEquals(false, CanTheUser.ups(listDoc), 'Assertion failed: CanTheUser.ups(\'Document__c\') should return true');

    }
    
    @isTest
    static void canCrudUpsDocumentPositive() {
        System.assertEquals(false, CanTheUser.ups(new Document__c()), 'Assertion failed: CanTheUser.ups(\'Document__c\') should return true');

    }
    
    @isTest
    static void canCrudUpsDocumentPositive1() {
        System.assertEquals(false, CanTheUser.ups('Document__c'), 'Assertion failed: CanTheUser.ups(\'Document__c\') should return true');

    }
    
    @isTest
    static void canCrudReadDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
            System.assertEquals(true, CanTheUser.read(listDoc), 'Assertion failed: CanTheUser.read(listDoc) should return true');

    }
    
    @isTest
    static void canCrudDestroyDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
        System.assertEquals(true, CanTheUser.destroy(listDoc), 'Assertion failed: CanTheUser.destroy(listDoc) should return true');

    }
    
    @isTest
    static void canCrudDestroyDocumentPositive() {
        System.assertEquals(true, CanTheUser.destroy('Document__c'), 'Assertion failed: CanTheUser.destroy(\'Document__c\') should return true');
    }

    @isTest
    static void canCrudAccountReadPositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.READ),
            'Expected to be able to read accounts'
        );
    }

    @isTest
    static void canCrudReadAccountPositive() {
        System.assert(
            CanTheUser.read(new Account()),
            'Expected to be able to read accounts'
        );
    }

    @isTest
    static void canCrudAccountUpdatePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.EDIT),
            'Expected to be able to update accounts'
        );
    }

    @isTest
    static void canCrudEditAccountPositive() {
        System.assert(
            CanTheUser.edit(new Account()),
            'Expected to be able to update accounts'
        );
    }

    @isTest
    static void canCrudAccountDeletePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.DEL),
            'Expected to be able to delete accounts'
        );
    }

    @isTest
    static void canCrudDestroyAccountPositive() {
        System.assert(
            CanTheUser.destroy(new Account()),
            'Expected to be able to delete accounts'
        );
    }

    @isTest
    static void getFLSofAccountIDNegative() {
        System.assert(
            CanTheUser.flsUpdatable('Account', 'id') == false,
            'Expected that the ID of an object cannot be updated.'
        );
    }

    @isTest
    static void memoizedFLSMDCcomparesAccesibleToUpdatable() {
        Test.startTest();
        CanTheUser.memoizeFLSMDC('Account', CanTheUser.FLSType.UPDATABLE);
        Test.stopTest();

        System.assertNotEquals(
            CanTheUser.accessibleFieldsByObject.get('Account'),
            CanTheUser.updatableFieldsByObject.get('Account'),
            'Expected that the two sets would be different'
        );
    }
    
    @isTest
    static void canCrudEditorDocumentPositive() {
        List<SObject> arr = new List<SObject> {new Document__c()};
        System.assertEquals(true, CanTheUser.crud(arr, CanTheUser.CrudType.DEL), 'Expected CRUD operation to return true');

    }
    
    @isTest
    static void canFLSDocumentPositive() {
        System.assertEquals(false, CanTheUser.flsAccessible('Document__c','Id'), 'Expected field-level security check to return false');
    }
    
    @isTest
    static void canFLScheckDocumentPositive() {
        Set<String> arr = new Set<String> {'Id','CreatedDate'};
        Map<String,Boolean> arrMap = new Map<String,Boolean> {'CreatedDate'=>false, 'Id'=>false};
       System.assertEquals(arrMap, CanTheUser.bulkFLSAccessible('Document__c', arr), 'Expected bulk field-level security check to match map');

    }
    
    @isTest
    static void canBULKFLScheckDocumentPositive() {
        Set<String> arr = new Set<String> {'Id','CreatedDate'};
        Map<String,Boolean> arrMap = new Map<String,Boolean> {'CreatedDate'=>false, 'Id'=>false};
        System.assertEquals(arrMap, CanTheUser.bulkFLSUpdatable('Document__c', arr), 'Expected bulk field-level security update check to match map');

    }    
}