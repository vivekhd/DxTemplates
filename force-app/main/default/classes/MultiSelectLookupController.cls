/**
 * Class		: MultiSelectLookupController
 * Developer	: 
 * Created Date	: 
 * @description	: Apex class for handling multi-select lookup functionality in Lightning components.
 *              Provides a method to retrieve records based on specified criteria and filter conditions.
 *              Utilizes a nested SObjectQueryResult class to structure and return query results.
 * 
 * Last Modified Date:
 */
public with sharing class MultiSelectLookupController {

	/**
     * @description Retrieves a list of SObjectQueryResult based on specified parameters.
     * @param objectName         String representing the API name of the target Salesforce object.
     * @param fieldAPINames      String containing a comma-separated list of API names of fields to retrieve.
     * @param filterFieldAPIName String representing the API name of the field to filter records based on.
     * @param strInput           String representing the input for record filtering.
     * @param whereClause        String representing additional WHERE clause conditions (optional).
     * @param whereClauseTwo     String representing additional WHERE clause conditions (optional).
     * @return List<SObjectQueryResult> A list of SObjectQueryResult objects containing record details.
     */
    @AuraEnabled
    public static List<SObjectQueryResult> retrieveRecords(String objectName, String fieldAPINames, String filterFieldAPIName, String strInput, String whereClause, String whereClauseTwo){
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        String strQuery;
        try {
            if (strInput.equals('*')) {
                strInput = '';
            }
            String str = '%' +strInput+ '%';
            String strQueryField = '';
            List<String> fieldList = fieldAPINames.split(',');

            if(!fieldList.contains('Id')) {
                fieldList.add('Id');
                strQueryField = String.join(fieldList, ',');
            } else {
                strQueryField = fieldAPINames;
            }            
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) +
                            + ' FROM '+ String.escapeSingleQuotes(objectName)
                            + ' WHERE '+ (String.isEmpty(whereClauseTwo)?' ':(String.valueOf(whereClauseTwo)) + ' AND ') + String.escapeSingleQuotes(filterFieldAPIName) + ' LIKE :str'
                            +   (String.isEmpty(whereClause)?' ':' AND '+String.escapeSingleQuotes(whereClause))
                            + ' WITH USER_MODE LIMIT 50';
            List<SObject> lstResult = database.query(strQuery);
            for(SObject sobj : lstResult){
                SObjectQueryResult result = new SObjectQueryResult();
                result.recordId = (String) sobj.get('Id');
                result.recordName = (String) sobj.get('Name');
                result.recordObject = sobj;
                lstReturnResult.add(result);  
            }
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'MultiSelectLookupController.retrieveRecords()','objectName -> '+objectName+' '+strQuery+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
        return lstReturnResult;  
    }

	/**
     * @description Inner class representing the structure of a single query result.
     *              Contains fields for the record ID, record name, and the full SObject record.
     */
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public sObject recordObject;
    }
}