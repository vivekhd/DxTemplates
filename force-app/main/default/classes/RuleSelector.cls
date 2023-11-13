public with sharing class RuleSelector {
  public static Safely safe = new Safely();

  public static List< Rule_Condition__c> getRuleConditions(String ruleId){
    List< Rule_Condition__c> ruleConditions;
    try{
      ruleConditions = [SELECT ID, Name,  Operator__c,  Evaluation_Object__c,  DataType__c,  Condition_Field__c,  Value__c,  ConditionIndex__c FROM  Rule_Condition__c WHERE  Rule__c =:ruleId WITH SECURITY_ENFORCED];
    } catch(Exception ex){
      LogHandler.createLog((Id) null,'RuleSelector',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
    }
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
        }
    } catch (Exception ex) {
      LogHandler.createLog((Id) null,'RuleSelector.deleteRuleConditions()','ruleId Id- '+ruleId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
    }  
  }
    
  public class SafeClassException extends Exception{}
}