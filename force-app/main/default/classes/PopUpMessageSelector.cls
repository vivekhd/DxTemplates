public with sharing class PopUpMessageSelector {
    //ATTRIBUTECOMPATABILITYRULES
	@AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_ONE_CONDITION = 'Please select atleast one condition';
    @AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_LIST_ACTION = 'Please select atleast one List Action';
    @AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_MANY_SUBMITS = 'To Many Submits are not accepted- please refresh the page';
    @AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_LIST_ACTION_DELETE = 'List Action(s) was Deleted';
    
    
	@AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_RULE_NAME = 'Please enter Rule Name';
	@AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_ONE_PRODUCT = 'Please select atleast one product';
	@AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_CONTACT_ADMINISTRATOR = 'Please contact your administrator';
	@AuraEnabled
    public final String ATTRIBUTECOMPATIBILITYRULES_CREATED = 'Attibute rule created successfully';
    //ATTRIBUTEGROUPSETUP
    @AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_CREATED = 'Group created successfully';
	@AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_UPDATED = 'Group(s) was Updated';
	@AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_DELETED = 'Group Deleted successfully';
    @AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_ONE_GROUP = 'Please select atleast one group';
    @AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_ASSIGNED = 'Attributes are assigned successfully';
    @AuraEnabled
    public final String ATTRIBUTEGROUPSETUP_DELETEFAIL = 'Group cannot be deleted as it is assigned to a product';
    //ATTRIBUTEPRICING
    @AuraEnabled
    public final String ATTRIBUTEPRICING_ALREADY_EXIST = 'Price combination exists already';
    @AuraEnabled
    public final String ATTRIBUTEPRICING_ALREADY_SAVED = 'Attribute Pricing was Saved';
    @AuraEnabled
    public final String ATTRIBUTEPRICING_ALREADY_DELETED = 'Attribute Pricing was Deleted';
    @AuraEnabled
    public final String ATTRIBUTEPRICING_ERROR_FETCH_PRICING = 'Error occurred while fetching Pricing Details.';
    @AuraEnabled
    public final String ATTRIBUTEPRICING_ALREADY_PP = 'Please select at least one attribute and product pricing';
    //ATTRIBUTESETUP
    @AuraEnabled
    public final String ATTRIBUTESETUP_ASSIGN_GROUP = 'Please select atleast one attribute to assign a group';
    @AuraEnabled
    public final String ATTRIBUTESETUP_DELETED = 'Attribute(s) was deleted';
    @AuraEnabled
    public final String ATTRIBUTESETUP_MANDATORY_VALUE = 'Please Complete Mandatory Fields or Row Value';
    @AuraEnabled
    public final String ATTRIBUTESETUP_CANNOT_DELETED = 'Attribute cannot be deleted as it is assigned to a product';
    @AuraEnabled
    public final String ATTRIBUTESETUP_MULTI_CANNOT_DELETED = 'Attributes cannot be deleted as it is assigned to a product';
    @AuraEnabled
    public final String ATTRIBUTESETUP_CREATED = 'Attribute(s) was created';
    @AuraEnabled
    public final String ATTRIBUTESETUP_UPDATED = 'Attibute(s) was updated';
    @AuraEnabled
    public final String ATTRIBUTESETUP_ASSIGNED = 'Attributes assigned to group(s) was saved';
    //CARTSETUP
    @AuraEnabled
    public final String CARTSETUP_INCLUSIVE = 'Inclusive product cannot be deleted';
    @AuraEnabled
    public final String CARTSETUP_FAVOURITE = 'Favourite was Successfully';
    @AuraEnabled
    public final String CARTSETUP_PB = 'Price Book was Created';
    @AuraEnabled
    public final String CARTSETUP_NOT_CONFIGURED = 'Price book entries are not configured for all the products in the Bundle';
    //CATEGORYSETUP
    @AuraEnabled
    public final String CATEGORYSETUP_CREATED = 'Category(s) was created';
    @AuraEnabled
    public final String CATEGORYSETUP_UPDATED = 'Category(s) was updated';
    @AuraEnabled
    public final String CATEGORYSETUP_DELETED = 'Category(s) was Deleted';
    @AuraEnabled
    public final String CATEGORYSETUP_CANNOT_DELETE_HAS_CHILD = 'Category cannot be deleted as this has a child category associated with it';
    @AuraEnabled
    public final String CATEGORYSETUP_CANNOT_DELETE_HAS_PRODUCT = 'Category cannot be deleted as there are product(s) associated with it';
    //COMPATABILITYRULE
    @AuraEnabled
    public final String COMPATABILITYRULE_CREATED = 'Rule created successfully';
    @AuraEnabled
    public final String COMPATABILITYRULE_ATLEAST_ONE_PRODUCT = 'Atleast one product should be selected';
    @AuraEnabled
    public final String COMPATABILITYRULE_NAME_DESC = 'Please enter Rule Name';
    @AuraEnabled
	public final String COMPATABILITYRULE_ATLEAST_ONE_CONDITION = 'Atleast one condition should be selected';
    //DXSHOWSELECTEDTEMPLATE
    @AuraEnabled
	public final String DXSHOWSELECTEDTEMPLATE_PDF ='PDF generated successfully, click Preview PDF to view';
    //DXTEMPLATESETUP
    @AuraEnabled
	public final String DXTEMPLATESETUP_CREATED = 'Template created successfully';
    @AuraEnabled
    public final String FILEUPLOAD_UPLOADED = 'Image was Uploaded';
    @AuraEnabled
    public final String FILEUPLOAD_DELETED = 'Image was Deleted';
    //FINALCARTPRODUCTS
	@AuraEnabled
	public final String FINALCARTPRODUCTS_DISCOUNT = 'Discount amount cannot be greater than the maximum amount:  {0}';
    @AuraEnabled
    public final String FINALCARTPRODUCTS_FAILED = 'Selected product(s) failed to Update';
    @AuraEnabled
    public final String FINALCARTPRODUCTS_RA = 'Please select the required attributes values';
    @AuraEnabled
    public final String FINALCARTPRODUCTS_FL = 'Product(s) Added to Favourite List';
    //PRICING RULE
    @AuraEnabled
    public final String PRICINGRULE_ADMIN = 'Some went Wrong in "Price Rule" : "Please contact your administrator"';
	//PRODUCTAGGREGATIONRULES
	@AuraEnabled
    public final String PRODUCTAGGREGATIONRULES_BUNDLE_PRODUCT = 'Bundle product should be selected';
    @AuraEnabled
    public final String PRODUCTAGGREGATIONRULES_ALREADY_RULE_ACTION = 'Rule action is already added';
    @AuraEnabled
    public final String PRODUCTAGGREGATIONRULES_SELECT_ACTION = 'Select products for rule action';
    @AuraEnabled
    public final String PRODUCTAGGREGATIONRULES_ADMIN = 'Error In Creating Bundle Rule(s)';
    
    //PRODUCTATTRIBUTESETUP
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_DELETED = 'Attribute(s) was Deleted';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_AVAILABLE_ATTRIBUTE_VALUES = 'Please select the Default Value from the available Attribute Values';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_DUPLICATE_ATTRIBUTES = 'Duplicate Attributes are selected! Duplicate Attributes:  {0}';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_SELETED_GROUP = 'Selected Group does not have any Attributes assigned!';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_PRODUCT = 'Attribute(s) assigned to Product(s) successfully';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_BEFORE_ASSIGNMENT = 'Please select the product before assignment.';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_VALUE_CANT_BE_EMPTY = 'Value cant be empty.';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_RECORD_SUCCESSFULL = 'Records are successfully updated.';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_ATTRIBUTE_DELETION = 'Select an attribute for deletion';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_ATTR_GROUP_DELETION = 'Select an attribute or group for deletion';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_ATTRIBUTE_CANNOTEDIT = 'Product Attribute(s) cannot edit from Assign Screen';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_DUPLICATE = 'Duplicate attribute or group selected';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_CANNOTDELETE_EXISTING= 'You cannot unassign/delete the existing Product Attribute(s)';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_PA = 'Product Attribute(s) was Created';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_SG = 'Same Group Selected';
    @AuraEnabled
    public final String PRODUCTATTRIBUTESETUP_PError = 'Error In Creating Product Attribute(s)';
    //PRODUCTPRICING
    @AuraEnabled
    public final String PRODUCTPRICING_MANDATORY = 'Price Book and price are mandatory';
    @AuraEnabled
    public final String PRODUCTPRICING_STANDARD_PRICE = 'Create a standard price before creating a custom price';
    @AuraEnabled
    public final String PRODUCTPRICING_PRICEBOOKENTRY = 'The price book entry cannot be deleted because there are references to it';
    //PRODUCTRELATIONSHIPSETUP
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_DELETED = 'Product Relationship(s) was deleted';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_CREATE_CHILD = 'Parent Product should be selected to create Product Relationship with the Child Product';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_PRICEBOOK = 'Please select a pricebook.';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_CREATED = 'Product Relationship(s) was created';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_UPDATED = 'Product Relationship(s) updated';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_ONCE = 'Please select only one Product Relationship at once!';
    @AuraEnabled
    public final String PRODUCTRELATIONSHIPSETUP_INVALIDDATA = 'Please Enter the Data before Saving!';
    //PRODUCTRULESETUP
    @AuraEnabled
    public final String PRODUCTRULESETUP_QUALIFICATION_DELETED = 'Qualification Rule(s) was deleted';
    @AuraEnabled
    public final String PRODUCTRULESETUP_COMPATIBILITY_DELETED = 'Compatibility Rule(s) was deleted';
    @AuraEnabled
    public final String PRODUCTRULESETUP_AGGREGATION_DELETED = 'Aggregation Rule(s) was deleted';
    @AuraEnabled
    public final String PRODUCTRULESETUP_PRICING_DELETED = 'Pricing Rule(s) was deleted';
    @AuraEnabled
    public final String PRODUCTRULESETUP_RULE_DELETED = 'Rule(s) was deleted';
    //PRODUCTSETUP
    @AuraEnabled
    public final String PRODUCTSETUP_ASSIGNED_CATEGORIES = 'Product(s) are assigned to categories successfully';
    @AuraEnabled
    public final String PRODUCTSETUP_CREATED = 'Product(s) was created';
    @AuraEnabled
    public final String PRODUCTSETUP_UPDATED = 'Product(s) was updated';
    @AuraEnabled
    public final String PRODUCTSETUP_CHILD_CREATED = 'Child product was created';
    @AuraEnabled
    public final String PRODUCTSETUP_DELETED = 'Product(s) was deleted';
    @AuraEnabled
    public final String PRODUCTSETUP_CANNOT_DELETED = 'Product cannot be deleted as it is associated with one of the Quote/Subscription/Opportunity/Asset';
    //QUALIFICATIONRULE
    @AuraEnabled
    public final String QUALIFICATIONRULE_CREATED = '';
    @AuraEnabled
    public final String QUALIFICATIONRULE_ATLEAST_ONE_PRODUCT = 'Please select atleast one product';
    @AuraEnabled
    public final String QUALIFICATIONRULE_UPDATED = 'Rule updated successfully';
    //sectionSetupCmp
    @AuraEnabled
    public final String SECTION_SETUP = 'Record(s) was Saved';
    //templatecontentDetails
    @AuraEnabled
    public final String TEMPLATECONTENT_RS = ' was Saved';
    @AuraEnabled
    public final String TEMPLATECONTENT_RD = 'Please Enter the Required Details';
    //templateDesignerCmp
    @AuraEnabled
    public final String TEMPLATE_DESIGN_UPDATED = ' was Saved';
    @AuraEnabled
    public final String TEMPLATE_DESIGN_DELETED = 'Deleted Successfully';
    //templateRelatedObjects
    @AuraEnabled
    public final String TEMPLATE_RELATED_OBJECT = 'Please Enter Name, Select Object & Fields before Saving';
    @AuraEnabled
    public final String TEMPLATE_RELATED_OBJECT_c = ' was Saved';
    //templateTableDetails
    @AuraEnabled
    public final String TEMPLATETABLE_DETAILS12 = 'Please Enter Name';
    //TEMPLATE HEADER
    @AuraEnabled
    public final String TEMPLATEHEADER_CREATED = ' was Saved';
    //TEMPLATE 
    @AuraEnabled
    public final String TEMPLATETABLE_DETAILS_C = 'Record(s) was Saved';
    @AuraEnabled
    public final String TEMPLATETABLE_DETAILS_D = 'Record(s) was Saved';
    
    
    @AuraEnabled(cacheable=true)
    public static PopUpMessageSelector getAllConstants() {
        return new PopUpMessageSelector();
    }
}