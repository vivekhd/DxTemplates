public with sharing class FooterClass {
    
    @AuraEnabled(cacheable = true)
    public static List<ContentVersion> getContentVersions(){
        List<ContentVersion> cvs = new List<ContentVersion>();
        String query= 'select id,FileExtension,title from ContentVersion where FileExtension in (\'jpg\', \'jpeg\', \'png\') WITH SECURITY_ENFORCED order by title asc';
        try{
            cvs = Database.query(query);  
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'FooterClass.getContentVersions()','Query -> '+ query +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }
        return cvs;
    }
    
    @AuraEnabled
    public static List<ContentVersion> getSearchedContentVersions(String searchlabel){
        searchlabel = '%' + searchlabel + '%';
        List<ContentVersion> cvs = new List<ContentVersion>();
        String query = ('select id,FileExtension,title from ContentVersion where FileExtension in (\'jpg\', \'jpeg\', \'png\') and title LIKE \'' + searchlabel + '\' WITH SECURITY_ENFORCED order by title asc');
        try{           
            cvs = Database.query(query);      
            System.debug(cvs);   		
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'FooterClass.getSearchedContentVersions()','Query -> '+ query +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }
        return cvs;
    }
}