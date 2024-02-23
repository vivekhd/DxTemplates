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
        System.assertEquals(
            CanTheUser.create('Document__c'),true
        );
    }
    
    @isTest
    static void canCrudCreateDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
		System.assertEquals(
           CanTheUser.create(listDoc),true
        );
    }
    
    @isTest
    static void canCrudReadDocumentPositive() {
        System.assertEquals(
            CanTheUser.read('Document__c'),true
        );
    }
    
   	@isTest
    static void canCrudEditDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
		System.assertEquals(
           CanTheUser.edit(listDoc),true
        );
    }
    
    @isTest
    static void canCrudEditDocumentPositive() {
        System.assertEquals(
            CanTheUser.edit('Document__c'),true
        );
    }
    
    @isTest
    static void canCrudUpsDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
		System.assertEquals(
           CanTheUser.ups(listDoc),false
        );
    }
    
    @isTest
    static void canCrudUpsDocumentPositive() {
        System.assertEquals(
            CanTheUser.ups(new Document__c()),false
        );
    }
    
    @isTest
    static void canCrudUpsDocumentPositive1() {
        System.assertEquals(
            CanTheUser.ups('Document__c'),false
        );
    }
    
    @isTest
    static void canCrudReadDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
		System.assertEquals(
           CanTheUser.read(listDoc),true
        );
    }
    
    @isTest
    static void canCrudDestroyDocumentListPositive() {
        List<Sobject> listDoc = new List<Sobject> {new Document__c()};
		System.assertEquals(
           CanTheUser.destroy(listDoc),true
        );
    }
    
    @isTest
    static void canCrudDestroyDocumentPositive() {
        System.assertEquals(
            CanTheUser.destroy('Document__c'),true
        );
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
        System.assertEquals(
            CanTheUser.crud(arr,CanTheUser.CrudType.DEL),true
        );
    }
    
    @isTest
    static void canFLSDocumentPositive() {
        System.assertEquals(
            CanTheUser.flsAccessible('Document__c','Id'),false
        );
    }
    
    @isTest
    static void canFLScheckDocumentPositive() {
        Set<String> arr = new Set<String> {'Id','CreatedDate'};
        Map<String,Boolean> arrMap = new Map<String,Boolean> {'CreatedDate'=>false, 'Id'=>false};
        System.assertEquals(
            CanTheUser.bulkFLSAccessible('Document__c',arr),arrMap
        );
    }
    
    @isTest
    static void canBULKFLScheckDocumentPositive() {
        Set<String> arr = new Set<String> {'Id','CreatedDate'};
        Map<String,Boolean> arrMap = new Map<String,Boolean> {'CreatedDate'=>false, 'Id'=>false};
        System.assertEquals(
            CanTheUser.bulkFLSUpdatable('Document__c',arr),arrMap
        );
    }    
}