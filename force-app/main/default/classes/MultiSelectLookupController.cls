public with sharing class MultiSelectLookupController {
    @AuraEnabled(cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, String fieldAPINames, String filterFieldAPIName, String strInput, String whereClause, String whereClauseTwo){
        try{
            List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
            if(strInput.equals('*')){
                strInput = '';
            }
            String str = '%' +strInput+ '%';
            String strQueryField = '';
            List<String> fieldList = fieldAPINames.split(',');

            if(!fieldList.contains('Id')){
                fieldList.add('Id');
                strQueryField = String.join(fieldList, ',');
            }else {
                strQueryField = fieldAPINames;
            }
            
            String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) +
                            + ' FROM '+ String.escapeSingleQuotes(objectName)
                            + ' WHERE '+ (String.isEmpty(whereClauseTwo)?' ':(String.valueOf(whereClauseTwo)) + ' AND ') + String.escapeSingleQuotes(filterFieldAPIName) + ' LIKE :str'
                            +(String.isEmpty(whereClause)?' ':' AND '+whereClause)
                            + ' WITH SECURITY_ENFORCED LIMIT 50';
            
            List<SObject> lstResult = database.query(strQuery);
            for(SObject sobj : lstResult){
                SObjectQueryResult result = new SObjectQueryResult();
                result.recordId = (String) sobj.get('Id');
                result.recordName = (String) sobj.get('Name');
                result.recordObject = sobj;
                lstReturnResult.add(result);  
            }
            return lstReturnResult;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'MultiSelectLookupController.retrieveRecords()','objectName -> '+objectName+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }  
    }

    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public sObject recordObject;
    }
}