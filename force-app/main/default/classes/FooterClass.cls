/**
* Class			    : FooterClass
* Developer			: 
* Created Date		: 
* @description		: Apex class for retrieving content versions, especially images (jpg, jpeg, png),
*              to be used in the footer section. Provides methods for retrieving all content versions
*              and searching for content versions based on a search label.
* Last Modified Date: 
*/
public with sharing class FooterClass {
    
	/**
    * @description Retrieves all content versions with file extensions 'jpg', 'jpeg', and 'png'.
    * @return List<ContentVersion> List of content versions.
    */
    @AuraEnabled(cacheable = true)
    public static List<contentversion> getContentVersions(){
        List<contentversion> cvs = new List<contentversion>();
        String query1= 'select id,FileExtension,title from contentversion where FileExtension in (\'jpg\', \'jpeg\', \'png\') WITH SECURITY_ENFORCED order by title asc';
        try{
            cvs = Database.query(query);  
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'FooterClass.getContentVersions()','Query -> '+ query +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }
        return cvs;
    }
    
	/**
    * @description Retrieves content versions with file extensions 'jpg', 'jpeg', and 'png'
    *               based on a search label.
    * @param searchlabel String representing the search label.
    * @return List<ContentVersion> List of content versions matching the search label.
    */
    @AuraEnabled
    public static List<contentversion> getSearchedContentVersions(String searchlabel){
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