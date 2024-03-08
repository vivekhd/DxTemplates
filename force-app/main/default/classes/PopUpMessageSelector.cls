/**
* Class			    : PopUpMessageSelector
* Developer			: 
* Created Date		: 
* @description  	:  A utility class providing constant strings for pop-up messages in various components.
*              			This class contains predefined messages for success and informational pop-ups.
*              			It is used to standardize and manage messages displayed to users in different scenarios.
* Last Modified Date: 
*/
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
    
	/**
     * @description Retrieves an instance of PopUpMessageSelector, providing access to predefined pop-up messages.
     * @return PopUpMessageSelector instance containing constant strings for pop-up messages.
     */
    @AuraEnabled(cacheable=true)
    public static PopUpMessageSelector getAllConstants() {
        return new PopUpMessageSelector();
    }
}