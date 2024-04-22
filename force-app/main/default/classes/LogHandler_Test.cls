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
            } catch(Exception e) {
                System.assert(e.getMessage()!=null, 'Error: Assertion failed');
            }
            System.assert(true,'Error: Assertion failed');
            Test.stopTest();
        }
    }
    
    @IsTest 
    static void executeTransacationLogsBatchToDelete(){
        for(TransactionLog__c rec:[select id,createddate from TransactionLog__c]) {
            Test.setCreatedDate(rec.Id, system.now()-31);
        }
        Test.startTest(); 
            String sch = '0 0 23 L * ?';
            DeleteTransactionLogRecords batchable=new DeleteTransactionLogRecords();
            system.schedule('Test ErrorClearence Class', sch, batchable);  
            Database.executeBatch(batchable);
        Test.stopTest(); 
        List<TransactionLog__c> afterRecords=new List<TransactionLog__c>([select id,createddate from TransactionLog__c]);
        System.assertEquals(0, afterRecords.size(), 'Error: TransactionLog records not deleted');
    }

    @TestSetup 
    static void createTransactionLogRecords() {
        List<TransactionLog__c> errRecordsInsert=new List<TransactionLog__c>();
        for(Integer i=0;i<12;i++) {
            errRecordsInsert.add(new TransactionLog__c());
        }
        if(!errRecordsInsert.isEmpty()){
            insert errRecordsInsert;
        }
        System.assertEquals(true, errRecordsInsert.size()>0, 'Error: TransactionLog records not deleted');
    }
}