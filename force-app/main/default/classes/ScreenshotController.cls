/**
* @File Name : ScreenshotController.cls
* @Description : This class is to resize images in Rich Text Area
* @Author : Bhavya Sri Khandrika
* @Last Modified By : September 26, 2024
* @Last Modified On : September 26, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 26, 2024 | Bhavya Sri Khandrika  | Initial Version
**/

public class ScreenshotController {
	 @AuraEnabled(cacheable=true)
    public static String getImageBase64(Id cvId) {
        String base64Data = '';
        
        try {
          ContentVersion cvData = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id =:cvId LIMIT 1];
          System.debug('Base64 Data: ' + EncodingUtil.base64Encode(cvData.VersionData));
            base64Data =  EncodingUtil.base64Encode(cvData.VersionData);

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        return base64Data;
    }
    
    @AuraEnabled
    public static String saveImage(String base64Data, String fileName, Id parentId) {
        try {
             List<Id> contentVersionIdsToDelete = new List<Id>();
             for (ContentVersion cv : [SELECT Id, ContentDocumentId  FROM ContentVersion WHERE FirstPublishLocationId = :parentId  WITH USER_MODE]) {
                    contentVersionIdsToDelete.add(cv.ContentDocumentId);
             } 
            List<Id> contentDocumentIdsToDelete = new List<Id>();
            List<ContentDocument> cdlst = [SELECT Id FROM ContentDocument WHERE Id IN :contentVersionIdsToDelete WITH USER_MODE];
            if (!cdlst.isEmpty()) {
                delete cdlst;
            }
            String base64Image = base64Data.split(',')[1]; 
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.FirstPublishLocationId  = parentId;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Image);
            insert contentVersion;
            
            return contentVersion.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving image: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String saveImageBase64(String base64Data) {
        String base64String = base64Data.split(',')[1];
        Blob imageBlob = EncodingUtil.base64Decode(base64String);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Resized Image';
        contentVersion.PathOnClient = 'resizedImage.png';
        contentVersion.VersionData = imageBlob;
        contentVersion.IsMajorVersion = true;
        insert contentVersion;        
        return contentVersion.Id;
    }
    
    @AuraEnabled
    public static void updateContentVersions(List<String> contentVersionIds, Id newLocationId) {
        System.debug('contentVersionIds ---> ' + contentVersionIds);
        System.debug('newLocationId ---> ' + newLocationId);
        List<ContentVersion> contentVersions = [
            SELECT Id, FirstPublishLocationId
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
        ];
        for (ContentVersion cv : contentVersions) {
            cv.FirstPublishLocationId = newLocationId;
        }
        try {
            update contentVersions;
        } catch (DmlException e) {
            System.debug('Error updating ContentVersions: ' + e.getMessage());
            throw new AuraHandledException('Error updating ContentVersions: ' + e.getMessage());
        }
    }
    
	/*@AuraEnabled
    public static void deleteContentVersions(List<String> cvIDs, Id docTempSectionId, List<String> allCVs) {
        System.debug('cvIDs ---> ' + cvIDs);
        System.debug('docTempSectionId ---> ' + docTempSectionId);
        List<ContentVersion> contentVersionsToDelete = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :allCVs 
        ];

        System.debug('Queried ContentVersions: ' + contentVersionsToDelete);
        Set<Id> contentDocumentIdsToDelete = new Set<Id>();
        for (ContentVersion cv : contentVersionsToDelete) {
            if (!cvIDs.contains(cv.Id)) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
            }
        }

        System.debug('ContentDocumentIds to delete: ' + contentDocumentIdsToDelete);

        if (!contentDocumentIdsToDelete.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinksToDelete = [
                SELECT Id
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :contentDocumentIdsToDelete
            ];

            System.debug('ContentDocumentLinks to delete: ' + contentDocumentLinksToDelete);
            if (!contentDocumentLinksToDelete.isEmpty()) {
                try {
                    delete contentDocumentLinksToDelete;
                    System.debug('Deleted ContentDocumentLinks successfully.');
                } catch (DmlException e) {
                    System.debug('Error deleting ContentDocumentLinks: ' + e.getMessage());
                    throw new AuraHandledException('Error deleting ContentDocumentLinks: ' + e.getMessage());
                }
            }
        }
    }
	*/
    
    
	@AuraEnabled
    public static void deleteContentVersions(List<String> rCVIDs, List<String> allCVs) {
        System.debug('rCVIDs ---> ' + rCVIDs);
        System.debug('allCVs ---> ' + allCVs);
    
        // Step 1: Retrieve all ContentVersion records based on the provided allCVs list.
        List<ContentVersion> contentVersionsToDelete = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :allCVs
        ];
    
        System.debug('Queried ContentVersions: ' + contentVersionsToDelete);
        
        Set<Id> contentDocumentIdsToDelete = new Set<Id>();
        for (ContentVersion cv : contentVersionsToDelete) {
            if (!rCVIDs.contains(cv.Id)) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
            }
        }
        System.debug('ContentDocumentIds to delete: ' + contentDocumentIdsToDelete);

        if (!contentDocumentIdsToDelete.isEmpty()) {
            List<ContentDocument> contentDocumentsToDelete = [
                SELECT Id
                FROM ContentDocument
                WHERE Id IN :contentDocumentIdsToDelete
            ];



            // List<ContentDocumentLink> contentDocumentLinksToDelete = [
            //     SELECT Id
            //     FROM ContentDocumentLink
            //     WHERE ContentDocumentId IN :contentDocumentIdsToDelete
            // ];
    
            // System.debug('ContentDocumentLinks to delete: ' + contentDocumentLinksToDelete);
            if (!contentDocumentIdsToDelete.isEmpty()) {
                try {
                    delete contentDocumentsToDelete;
                    System.debug('Deleted contentDocumentIdsToDelete successfully.');
                } catch (DmlException e) {
                    System.debug('Error deleting contentDocumentIdsToDelete: ' + e.getMessage());
                    throw new AuraHandledException('Error deleting contentDocumentIdsToDelete: ' + e.getMessage());
                }
            }
        }
    }






}