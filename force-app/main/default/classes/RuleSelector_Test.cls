@isTest
public class RuleSelector_Test {
    
    @isTest
    public static void testSavepointOperation() {
        Rule__c rule= new Rule__c();
        insert rule;
        Rule_Condition__c testRecord = new Rule_Condition__c(DxCPQ__Rule__c=rule.id);
        Rule_Condition__c testRecord1 = new Rule_Condition__c(DxCPQ__Rule__c=rule.id);
        
        insert new List<Rule_Condition__c>{testRecord,testRecord1};
        List<Id> arrIds = new List<Id>{testRecord.Id, testRecord1.Id};
        Test.startTest();
        try{
            RuleSelector.deleteRuleConditions(arrIds);
        }
        catch (exception ex){
            System.assert(ex.getMessage().contains('Script-thrown exception'),true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testSavepointOperation1() {
        Rule__c rule= new Rule__c();
        insert rule;
        Rule_Condition__c testRecord = new Rule_Condition__c(DxCPQ__Rule__c=rule.id);
        Rule_Condition__c testRecord1 = new Rule_Condition__c(DxCPQ__Rule__c=rule.id);
        
        insert new List<Rule_Condition__c>{testRecord,testRecord1};
        List<Id> arrIds = new List<Id>{null,null};
        Test.startTest();
        try{
            RuleSelector.deleteRuleConditions(arrIds);
        }
        catch (exception ex){
            System.assert(ex.getMessage().contains('Script-thrown exception'),true);
        }       
        Test.stopTest();           
    }    
    
    @isTest
    public static void testRelatedObjectsRestConditions() {
        Test.startTest();
        Rule__c rule= new Rule__c();
       	insert rule;  
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){          
        	String arr = RelatedObjectsClass.handleTemplateRuleResetCondition(rule.Id);
            System.assertEquals('Success', arr, 'Unexpected result');
        }
        Test.stopTest();        
    }    
    
    @isTest
    public static void testRelatedObjectsRestConditions1() {
        Test.startTest();
        Rule__c rule= new Rule__c();
       	insert rule;  
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){          
        	String arr = RelatedObjectsClass.handleTemplateRuleResetCondition(null);
           System.assertEquals('Error', arr, 'Unexpected result');
        }
        Test.stopTest();        
    } 
}