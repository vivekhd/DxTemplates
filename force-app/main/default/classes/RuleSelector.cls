public with sharing class RuleSelector {
  public static Safely safe = new Safely();

  public static List< Rule_Condition__c> getRuleConditions(String ruleId){
    List< Rule_Condition__c> ruleConditions = [SELECT ID, Name,  Operator__c,  Evaluation_Object__c,  DataType__c,  Condition_Field__c,  Value__c,  ConditionIndex__c FROM  Rule_Condition__c WHERE  Rule__c =:ruleId WITH SECURITY_ENFORCED];
    return ruleConditions;
  }

  public static void deleteRuleConditions(List<Id> deleteIds){
    String ruleId='';
    try {
    List< Rule_Condition__c> ruleConditions = [SELECT ID FROM  Rule_Condition__c WHERE ID IN :deleteIds WITH SECURITY_ENFORCED];
    ruleId = ruleConditions[0].ID;
        Savepoint sp = Database.setSavepoint();
    List<Database.DeleteResult> deleteResult = safe.doDelete(ruleConditions);
        List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
        if(errorList.size()>0){
          Database.rollback(sp);
          throw new SafeClassException(String.join( errorList, ', ' ));
        }
    } catch (Exception ex) {
        system.debug('messageeee>>>>>'+ex.getMessage());
      LogHandler.createLog((Id) null,'RuleSelector.deleteRuleConditions()','ruleId Id- '+ruleId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
      throw new AuraHandledException(ex.getMessage());
  }  
  }
    
  public class SafeClassException extends Exception{          
  }
}