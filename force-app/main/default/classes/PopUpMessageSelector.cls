public with sharing class PopUpMessageSelector {

    //DXSHOWSELECTEDTEMPLATE
    @AuraEnabled
	public final String DXSHOWSELECTEDTEMPLATE_PDF ='PDF generated successfully, click Preview PDF to view';

    //templateDesignerCmp
    @AuraEnabled
    public final String TEMPLATE_DESIGN_UPDATED = ' was Saved';
    @AuraEnabled
    public final String TEMPLATE_DESIGN_DELETED = 'Deleted Successfully';
    @AuraEnabled
    public final String TEMPLATEHEADER_CREATED = ' was Saved';
    
    @AuraEnabled(cacheable=true)
    public static PopUpMessageSelector getAllConstants() {
        return new PopUpMessageSelector();
    }
}