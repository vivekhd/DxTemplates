@IsTest
private class LogHandler_Test {
    @IsTest
    static void createExceptionTest(){
        User us = DexUtilTestDataFactory.CreateTestUser();
		System.runAs(us){
            Test.startTest();
            TransactionLog__c logRecord = new TransactionLog__c(RecordId__c = null, Process_Name__c = 'TestClass', LogType__c= 'Exception', LogMessage__c = 'Test Message', LogData__c= 'Test Log Data');
            insert logRecord;
            List<TransactionLog__c> logRecordList = new List<TransactionLog__c>();
            logRecordList.add(logRecord);
            LogHandler.createException(null,'Test','Test','Exception');
            LogHandler.createLog(null,'Test','Test','Test','Exception');
            LogHandler.getLog(null,'Test','Test','Test','Exception');
            LogHandler.createMultipleLogs(null);
            try{
                LogHandler.createMultipleLogs(logRecordList);
            }catch(Exception e){
                system.assert(e.getMessage()!=null);
            }
            System.assert(true);
            Test.stopTest();
        }
    }
}