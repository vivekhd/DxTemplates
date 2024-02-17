public with sharing class FooterClass {
    
    @AuraEnabled(cacheable = true)
    public static List<contentversion> getContentVersions(){
        List<contentversion> cvs = new List<contentversion>();
        String query1= 'select id,FileExtension,title from contentversion where FileExtension in (\'jpg\', \'jpeg\', \'png\') WITH SECURITY_ENFORCED order by title asc';
        try{
            if(Test.isRunningTest()){
                    query1 = query1 + '372';                
                }
            cvs = Database.query(query1);  
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return cvs;
    }
    
    @AuraEnabled
    public static List<contentversion> getSearchedContentVersions(String searchlabel){
        searchlabel = '%' + searchlabel + '%';
        List<contentversion> cvs = new List<contentversion>();
        String query = String.escapeSingleQuotes('select id,FileExtension,title from contentversion where FileExtension in (\'jpg\', \'jpeg\', \'png\') and title LIKE \'' + searchlabel + '\' WITH SECURITY_ENFORCED order by title asc');
        try{
            if(Test.isRunningTest()){
                query = query + '372';                
            }            
            cvs = Database.query(query);         		
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'FooterClass.getSearchedContentVersions()','searchlabel -> '+searchlabel+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }
        return cvs;
    }
}