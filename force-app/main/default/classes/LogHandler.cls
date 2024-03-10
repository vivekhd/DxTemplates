/**
* @description       : Generic Class to create records into TransactionLog__c object
* @author            : DX
* @Created on        : 21 March-2022
* Change Log         : 
**/
public with sharing class LogHandler {
    
    public class SafeClassException extends Exception{ }
    public static Safely safe = new Safely();
    /**
    * This method can be called from any component.It is used to create a record in TransactionLog__c
    * in case of any exception in the code.
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
    * This method can be called from any component.It is used to create a record in TransactionLog__c,
    * it can be an exception or just the transaction information.
    * 
    * @param ipInput recordid,ClassName, Exception, LogData, LogType
    * @param Output  Void
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
    * This method can be called from any component.It is used to create multiple records in TransactionLog__c,
    * it can be an exception or just the transaction information.
    * 
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
    * This method can be called from any component.It will create an instance of TransactionLog__c record & returns it,
    * it can be an exception or just the transaction information.
    * 
    * @param ipInput recordid,ClassName, Exception, LogData, LogType
    * @param Output  TransactionLog__c
    */
    public static TransactionLog__c getLog(Id recordId,String className,String exceptionMessage,String logData,String logType) {
        TransactionLog__c logRecord = new TransactionLog__c(RecordId__c = recordId,  Process_Name__c = className, LogType__c=logType, LogMessage__c = exceptionMessage, LogData__c=logData);
        return logRecord;    
    }
    
}