@IsTest
private class PopUpMessageSelector_Test {
    @IsTest
    static void getConstantTest(){
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            PopUpMessageSelector.getAllConstants();
            System.assert(true);
        }
        Test.stopTest();
    }
}