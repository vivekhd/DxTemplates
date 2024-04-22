/**
* Class			    : LogHandler
* @description       : Apex class for handling logging and exception management.
 *              Provides methods for creating logs in the TransactionLog__c object,
 *              handling exceptions, and managing log data.
* @author            : DX
* @Created on        : 21 March-2022
* Change Log         : 
**/
public with sharing class LogHandler { 
    public static Safely safe = new Safely();

    /**
    * This method can be called from any component.It is used to create a record in TransactionLog__c  in case of any exception in the code.
    * @param ipInput recordid,ClassName, Exception, LogData
    * @param Output  Void
    */
    public static void createException(Id recordId,String className,String exceptionMessage,String LogData) {  
        try {
            if(exceptionMessage.length() > 131072) { exceptionMessage = exceptionMessage.SubString(0,131072); }
            if(LogData.length() > 131072) { exceptionMessage = exceptionMessage.SubString(0,131072); }
            TransactionLog__c exceptionLog = new TransactionLog__c(RecordId__c = recordId, Process_Name__c = className, LogMessage__c = exceptionMessage, LogData__c=LogData, LogType__c='Exception');
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult[] srList = safe.doInsert(exceptionLog);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(srList);
            if(errorList.size()>0) {
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }

    /**
     * @description Creates a log record in the TransactionLog__c object.
     * @param recordId Id of the related record.
     * @param className Name of the class where the log is created.
     * @param exceptionMessage Log message or exception message.
     * @param logData Additional log data.
     * @param logType Type of log (e.g., 'Exception', 'Info').
     */
    @AuraEnabled
    public static void createLog(Id recordId,String className,String exceptionMessage,String LogData, String logType) {
        try {
            if(exceptionMessage.length() > 131072) { exceptionMessage = exceptionMessage.SubString(0,131072); }
            if(LogData.length() > 131072) { exceptionMessage = exceptionMessage.SubString(0,131072); }
            TransactionLog__c exceptionLog = new TransactionLog__c(RecordId__c = recordId, Process_Name__c = className, LogMessage__c = exceptionMessage, LogData__c=LogData, LogType__c=logType);
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult[] srList = safe.doInsert(exceptionLog);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(srList);
            if(errorList.size()>0) {
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
    * This method can be called from any component.It is used to create multiple records in TransactionLog__c, it can be an exception or just the transaction information.
    * @param ipInput List of TransactionLog__c records
    * @param Output  Void
    */
    public static void createMultipleLogs(List<TransactionLog__c> listrecords) {
        try {
            if(listrecords!=null && listrecords.size()>0){
                Savepoint sp = Database.setSavepoint();
                Database.SaveResult[] srList = safe.doInsert(listrecords);
                List<String> errorList = Safely.safeClassExceptionHandlerInsert(srList);
                if(errorList.size()>0){
                    Database.rollback(sp);
                    throw new SafeClassException(String.join( errorList, ', ' ));
                }
            } 
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
        
    }
    
    /**
     * @description Creates an instance of TransactionLog__c record without inserting it.
     * @param recordId Id of the related record.
     * @param className Name of the class where the log is created.
     * @param exceptionMessage Log message or exception message.
     * @param logData Additional log data.
     * @param logType Type of log (e.g., 'Exception', 'Info').
     * @return TransactionLog__c
     */
    public static TransactionLog__c getLog(Id recordId,String className,String exceptionMessage,String logData,String logType) {
        TransactionLog__c logRecord = new TransactionLog__c(RecordId__c = recordId,  Process_Name__c = className, LogType__c=logType, LogMessage__c = exceptionMessage, LogData__c=logData);
        return logRecord;    
    }
    
	/**
     * @description Inner class representing a custom exception for safe class operations.
     */
    public class SafeClassException extends Exception{ }
}