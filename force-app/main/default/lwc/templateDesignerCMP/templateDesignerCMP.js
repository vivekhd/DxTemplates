import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveDocumentTemplateSectionSequences from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionSequences';
import getAllDocumentTemplateSections from '@salesforce/apex/SaveDocumentTemplatesection.getAllDocumentTemplateSections';
import activateTemplate from '@salesforce/apex/SaveDocumentTemplate.activateTemplate';
import deleteTemplate from '@salesforce/apex/SaveDocumentTemplate.deleteTemplate';
import {  loadStyle } from 'lightning/platformResourceLoader';
import dxQuoteTemplate from '@salesforce/resourceUrl/dxQuoteTemplate';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';
import saveContentVersion from '@salesforce/apex/DisplayPDFController.saveContentVersion';
import { updateRecord } from 'lightning/uiRecordApi';
import DOCUMENTTEMPLATEID_FIELD from '@salesforce/schema/Document_Template__c.Id';
import WATERMARKDATA_FIELD from '@salesforce/schema/Document_Template__c.Watermark_Data__c';
import getSFDomainBaseURL from '@salesforce/apex/DisplayPDFController.getSFDomainBaseURL';
import getDocumentTemplateData from '@salesforce/apex/DisplayPDFController.getDocumentTemplateData';
import createLog from '@salesforce/apex/LogHandler.createLog';

export default class TemplateDesignerCMP extends NavigationMixin(LightningElement) {
  @api recordId; // Selected Template ID

  //variables added by Bhavya for watermark starts here

  step = 1; // progress bar increases with a step value 1
  currentStep = "1"; // It reflects the current (or) active step in the progress bar
  baseURL; // domain base url of the ORG
  imageUrl; // it stores the data of the uploaded image
  @track activeTab =''; // It stores the active tab value
  @track outerContainer = ''; //The styling of the container which holds the canvas
  @track watermarkText  = ''; // The input text value with which text watermark is being created
  @track showwatermarkbtn = false; // This variable controls the display of the Watermark Popup in HTML
  @track fontSizeValue  =  '22'; // Default Font Size = 22
  @track rotationValue = '0'; // Default Text Rotation Value = 0
  @track rotationImagevalue = '0'; // Default Image Rotation Value = 0
  previousRotationValue = '0'; // This variable stores the previous text rotation value, used for comparing with the current userinput text rotation value
  previousImgRotationValue = '0'; // This variable stores the previous image rotation value, used for comparing with the current userinput image rotation value
  @track colorValue = '#000000'; // Default watermark text color #000000
  @track opacityImageValue = '1.0'; // Default Image Opacity = 1
  @track checkedValText = true; // Default text watermark checkbox (isPrimary) is checked, true
  @track checkedValImage = false; // Default Image watermark checkbox (isPrimary) is unchecked, false
  @track imageScalingValue = 100; // Default Image scaling = 100
  @track opacityValue = '1.0'; // Default text Opacity = 1
  @track pageTextOption = 'All Pages - Text'; // Default text page Option for watermark is selected as "ALL PAGES"
  @track pageImageOption = 'All Pages - Image'; // Default Image page Option for watermark is selected as "ALL PAGES"
  @track readonlyVal = false; // Boolean to make the field readonly
  //watermarkPageOptionsText combobox options for Text Watermark
  watermarkPageOptionsText = [
        { label: 'All Pages', value: 'All Pages - Text', checked : true },
        { label: 'All Pages Except First Page', value: 'All Pages Except First Page - Text' , checked : false},
    ];
  //watermarkPageOptionsImage combobox options for Image Watermark
  watermarkPageOptionsImage = [
        { label: 'All Pages', value: 'All Pages - Image' , checked : true},
        { label: 'All Pages Except First Page', value: 'All Pages Except First Page - Image', checked : false },
    ];
  //fontSizeOptions combobox options for Text Watermark
  get fontSizeOptions() {
    const options = [];
    for (let i = 8; i <= 28; i += 2) {
        options.push({
            label: i.toString(),
            value: i.toString()
        });
    }
    return options;
  }
  //opacityOptions combobox options for both Text & Image Watermark
   get opacityOptions() {
    const options = [];
    for (let i = 1; i >= 0; i -= 0.1) {
        options.push({
            label: i.toFixed(1),
            value: i.toFixed(1)
        });
    }
    return options;
  }

    //Variables added for watermark by Bhavya ends here 

value = ''; // Variable used to store the event value.
rowCount = -1; // Section count/index of the section in the sections stack.
selectedOption; // Variable for storing selected options.
isLoaded = false; // Flag to indicate whether the component is loaded.
SectionTypename; // Variable to store the section type name.
recordidtoedit = ''; // ID of the record to edit.
firstsectionrecord; // First section record.
editTemplate = false; // Flag to indicate whether to show the edit the template screen or not.
opensection = false; // Flag to indicate whether to open a section.
disableEditing = false; // Flag to indicate whether editing is disabled.
showtabledetails = false; // Flag to indicate whether to show/hide table details.
showclausescreen = false; // Flag to indicate whether to show/hide the clause screen.
showheaderdetails = false; // Flag to indicate whether to show/hide header details.
showfooterdetails = false; // Flag to indicate whether to show/hide footer details.
showCloneTemplate = false; // Flag to indicate whether to show the clone template popup.
showAddNewTemplate = false; // Flag to indicate whether to show the add new template popup.
showDeleteTemplate = false; // Flag to indicate whether to show the delete template popup.
documenttemplaterecordid; // ID of the document template record.
showcontextdetails = false; // Flag to indicate whether to show the context details section.
selectedSectionRecordID = ''; // ID of the selected section record.
isconnectedcalledonLoad = false; // Flag to indicate whether connected is called on load.
showrelatedobjectdetails = false; // Flag to indicate whether to show related object details section.
activateTemplateLabel = 'Activate Template'; // Label for activating the template.
@track showPreview = false; // Flag to indicate whether to show/hide the preview.
@track previewModal = false; // Flag to indicate whether to show/hide the preview modal.
previewLabel = ''; // Label for the preview.
@track showTemplate = false; // Flag to indicate whether to show/hide the template.
isconnectedcalledondeletion = false; // Flag to indicate whether connected is called on deletion.
previewRecordId; // ID of the preview record.
templateId; // ID of the template.
templatename; // Name of the template.
@api relatedtoTypeObjName; // Related to type object name.
@track relatedtoTypeObjChild; // Child of the related to type object.
quoteName; // Name of the quote.
popUpMessage; // Popup message.


  @wire(getAllPopupMessages)
  allConstants({ error, data }) {
    if (data) {
      this.popUpMessage = data;
      console.log('Success');
    } else {
      this.error = error;
    }
  }

  @track doctemplatedetails = {
    Id: '',
    Name: '',
    DxCPQ__Related_To_Type__c: '',
    DxCPQ__IsActive__c: false,
    DxCPQ__Version_Number__c: '', DxCPQ__Previously_Active__c: false, DxCPQ__Parent_Template__c: ''
  };

  constructor() {
    super();
  }

  /**
  * Sets the record ID and related field values based on the provided document information.
  * Calls the connectedCallback method.
  * @param {Object} doc The document information.
  */
  @api handleConnectedCallback(doc) {
    this.recordId = doc.Id;
    this.doctemplatedetails.Id = doc.Id;
    this.doctemplatedetails.DxCPQ__Related_To_Type__c = doc.DxCPQ__Related_To_Type__c;
    this.relatedtoTypeObjName = doc.DxCPQ__Related_To_Type__c;
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    this.isconnectedcalledonLoad = false;
    this.connectedCallback();
  }

  /**
  * Method to receive an object name and perform related actions based on the object name.
  * Sets the object name received as the value for the relatedtoTypeObjChild property in the component.
  * Calls the handleObjectNameSelection method of the c-template-content-details and c-template-related-objects components with the object name as a parameter.
  * (Commented out) Calls the handleObjectNameSelection method of the c-template-footer-type and c-template-header-type components with the object name as a parameter.
  * @param {String} objName The name of the object being passed.
  * @returns The object name passed as a parameter.
  */
  @api passingObject(objName) {
    this.relatedtoTypeObjChild = objName;
    this.template.querySelector("c-template-content-details").handleObjectNameSelection(this.relatedtoTypeObjName);
    this.template.querySelector("c-template-related-objects").handleObjectNameSelection(this.relatedtoTypeObjName);
    /* Commented by Rahul -> Merge Fields in Header and Footer */
    // this.template.querySelector("c-template-footer-type").handleObjectNameSelection(this.relatedtoTypeObjName);
    // this.template.querySelector("c-template-header-type").handleObjectNameSelection(this.relatedtoTypeObjName);
  }

  /**
    * Method to handle child components based on the selected option, new section status, and section ID.
    * @param {String} selectedOption The selected option for the section ('Clause', 'Context', 'Related Objects', 'Table', 'Header', or 'Footer').
    * @param {Boolean} isNewSection Indicates whether the section is new or not.
    * @param {String} sectionid The ID of the section.
    */
  handlechildcomponents(selectedOption, isNewSection, sectionid) {
    console.log('selectedOption in function-' + selectedOption);
    if (selectedOption == 'Clause') {
      this.showclausescreen = true;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = false;
      this.SectionTypename = 'Clause';
      this.opensection = true;
      this.showcontextdetails = true;
      this.showheaderdetails = false;
      this.showfooterdetails = false;
      if (isNewSection == true) {
        this.rowCount += 1;
        this.optionsList.push({ Id: selectedOption + 'NotSaved', Type: selectedOption, rowCount: this.rowCount });
        this.selectedSectionRecordID = selectedOption + 'NotSaved';
        this.connectedCallback();
      } else {
        this.template.querySelector("c-template-content-details").loadsectionsectionvaluesforedit(sectionid);
        this.showPreview = true;
      }
    }
    else if (selectedOption == 'Context') {
      this.showclausescreen = false;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = false;
      this.SectionTypename = 'Context';
      this.opensection = true;
      this.showcontextdetails = true;
      this.showheaderdetails = false;
      this.showfooterdetails = false;
      if (isNewSection == true) {
        this.rowCount += 1;
        this.optionsList.push({ Id: selectedOption + 'NotSaved', Type: selectedOption, rowCount: this.rowCount });
        this.selectedSectionRecordID = selectedOption + 'NotSaved';
        this.connectedCallback();
      } else {
        this.template.querySelector("c-template-content-details").loadsectionsectionvaluesforedit(sectionid);
        this.showPreview = true;
      }
    }
    else if (selectedOption == 'Related Objects') {
      this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
      this.showclausescreen = false;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = true;
      this.SectionTypename = 'Related Objects';
      this.opensection = true;
      this.showcontextdetails = false;
      this.showheaderdetails = false;
      this.showfooterdetails = false;
      if (isNewSection == true) {
        this.rowCount += 1;
        this.optionsList.push({ Id: selectedOption + 'NotSaved', Type: selectedOption, rowCount: this.rowCount });
        this.selectedSectionRecordID = selectedOption + 'NotSaved';
        this.connectedCallback();
      } else {
        this.template.querySelector("c-template-related-objects").loadsectionsectionvaluesforedit(sectionid);
        this.showPreview = true;
      }
    }

    else if (selectedOption == 'Table') {
      this.showclausescreen = false;
      this.showtabledetails = true;
      this.showrelatedobjectdetails = false;
      this.SectionTypename = 'Table';
      this.opensection = true;
      //this.isModalOpen = false;
      this.showcontextdetails = false;
      this.showheaderdetails = false;
      this.showfooterdetails = false;
      console.log('isNewSection' + isNewSection);
      if (isNewSection == true) {
        this.rowCount += 1;
        this.optionsList.push({ Id: selectedOption + 'NotSaved', Type: selectedOption, rowCount: this.rowCount });
        this.selectedSectionRecordID = selectedOption + 'NotSaved';
        this.connectedCallback();
      } else {
        this.template.querySelector("c-template-table-details").loadsectionsectionvaluesforedit(sectionid);
        this.showPreview = true;

      }
    }
    else if (selectedOption == 'Header') {
      this.showclausescreen = false;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = false;
      this.SectionTypename = 'Header';
      console.log('Option selected with value: ' + selectedOption);
      this.opensection = true;
      this.showcontextdetails = false;
      this.showheaderdetails = true;
      this.showfooterdetails = false;

      if (isNewSection == true) {
        this.template.querySelector("c-template-header").loadsectionsvaluesforCreation();
      } else {
        this.template.querySelector("c-template-header").loadsectionvaluesforedit(this.header.Id);
        this.showPreview = true;
      }
    } else if (selectedOption == 'Footer') {
      this.showclausescreen = false;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = false;
      this.opensection = true;
      this.showcontextdetails = false;
      this.showheaderdetails = false;
      this.showfooterdetails = true;
      if (isNewSection == true) {
        this.template.querySelector("c-template-footer").loadsectionsvaluesforCreation();
      } else {
        this.template.querySelector("c-template-footer").loadsectionvaluesforedit(this.footer.Id);
        this.showPreview = true;
      }
    }
  }
  /**
   * Method to add a new Context section to the sections stack
  */
  handleNewContext() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    const selectedOption = 'Context';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }
  /**
   * Method to add a new Related Objects section to the sections stack
  */
  handleNewRelatedObjects() {
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-related-objects").resetvaluesonchildcmp();
    this.template.querySelector("c-template-related-objects").assignDocTempId(this.doctemplatedetails.Id);
    const selectedOption = 'Related Objects';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }
  /**
   * Method to add a new Clause section to the sections stack
  */
  handleNewClause() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    const selectedOption = 'Clause';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }

  /**
   * Method to add a new Table section to the sections stack
  */
  handleNewTable() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-table-details").resetvaluesonchildcmp();
    this.template.querySelector("c-template-table-details").assignDocTempId(this.doctemplatedetails.Id);
    const selectedOption = 'Table';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }

  /**
    * Method to handle the data saved for a section.
    * Retrieves the saved section record ID from the event detail.
    * Iterates through the optionsList array to update the section name if the ID contains 'NotSaved' or matches the saved section record ID.
    * Sets the selected section record ID to the saved section record ID.
    * Calls the connectedCallback method to refresh the component.
    * If the showPreview property is false, sets it to true.
    * @param {CustomEvent} event The event containing the saved section record ID and name.
    */
  handlesavedsectiondata(event) {
    var secrecordId = event.detail.Id;
    this.optionsList.forEach(function (val) {
      var str = val.Id;
      if (str.indexOf('NotSaved') !== -1) {
        val.sectionNameEntered = event.detail.Name;
        val.Id = event.detail.Id;
      }
      else if (str.indexOf(secrecordId) !== -1) {
        val.sectionNameEntered = event.detail.Name;
      }
    });
    this.selectedSectionRecordID = secrecordId;
    this.connectedCallback();
    if (this.showPreview == false) { this.showPreview = true; }
  }
  
  /**
   * Method to save the Header data when clicked Save/update
   */
  handlesavedheaderdata(event) {
    this.header.Id = event.detail.Id;
    if (this.showPreview == false) { this.showPreview = true; }
  }

  /**
   * Method to save the footer data when clicked Save/update
   */
  handlesavedfooterdata(event) {
    this.footer.Id = event.detail.Id;
    if (this.showPreview == false) { this.showPreview = true; }
  }

  /**
 * Method to delete the section of the current template
 */
  handledeletesectiondata() {
    this.isconnectedcalledondeletion = true;
    this.connectedCallback();
  }

  /**
   * Method to handle a header click event. 
   * Adds the "active" class to the element with the data-id attribute equal to this.header.Id.
   * Removes the "active" class from all elements with data-id attributes equal to index in this.sections.
   * Removes the "active" class from the element with the data-id attribute equal to this.footer.Id.
   * Calls the displaysectionbasedontype method with this.header.Id and this.header.Type as parameters.
   */
  handleHeaderClick() {
    const elm = this.template.querySelector(`[data-id="${this.header.Id}"]`);
    elm.classList.add("active");
    this.sections.forEach((loopvar, index) => {
      const elm2 = this.template.querySelector(`[data-id="${index}"]`);
      elm2.classList.remove("active");
    });
    const elmfooter = this.template.querySelector(`[data-id="${this.footer.Id}"]`);
    elmfooter.classList.remove("active");
    this.displaysectionbasedontype(this.header.Id, this.header.Type);
  }

  /**
    * Method to handle the click event on the footer section.
    * Retrieves the footer element using the footer ID and adds the 'active' class to it.
    * Removes the 'active' class from all other sections.
    * Retrieves the header element using the header ID and removes the 'active' class from it.
    * Calls the displaysectionbasedontype method to display the footer section.
    */
  handleFooterClick() {
    const elm = this.template.querySelector(`[data-id="${this.footer.Id}"]`);
    elm.classList.add("active");
    this.sections.forEach((loopvar, index) => {
      const elm2 = this.template.querySelector(`[data-id="${index}"]`);
      elm2.classList.remove("active");
    });
    const elmheader = this.template.querySelector(`[data-id="${this.header.Id}"]`);
    elmheader.classList.remove("active");
    this.displaysectionbasedontype(this.footer.Id, this.footer.Type);
  }

  /**
    * Method triggered when a section is clicked.
    * Adds the 'active' class to the clicked section.
    * Removes the 'active' class from all other sections.
    * Removes the 'active' class from the header and footer sections.
    * Sets the 'selectedSectionRecordID' and 'recordidtoedit' variables based on the clicked section.
    * Calls the displaysectionbasedontype method to display the section based on its type and ID.
    * @param {Event} event The event object containing information about the click event.
    * @returns undefined.
    */
  handleSectionClick(event) {
    const itemIndex = event.currentTarget.dataset.id;
    const elm = this.template.querySelector(`[data-id="${itemIndex}"]`);
    elm.classList.add("active");
    this.sections.forEach((loopvar, index) => {
      if (itemIndex != index) {
        const elm2 = this.template.querySelector(`[data-id="${index}"]`);
        elm2.classList.remove("active");
      }
    });

    const elmheader = this.template.querySelector(`[data-id="${this.header.Id}"]`);
    elmheader.classList.remove("active");

    const elmfooter = this.template.querySelector(`[data-id="${this.footer.Id}"]`);
    elmfooter.classList.remove("active");

    const rowData = this.sections[itemIndex];
    this.selectedSectionRecordID = rowData.Id;
    this.recordidtoedit = rowData.Id;
    this.displaysectionbasedontype(this.recordidtoedit, rowData.Type);
  }

  /**
    * Method to display a section based on its type and ID.
    * If the section type is 'Header' or 'Footer', checks if the section ID contains the string 'NotSaved' to determine if the section is new.
    * Calls the handlechildcomponents method with the section type, new status, and section ID as parameters.
    * If the section type is not 'Header' or 'Footer', calls the handlechildcomponents method with the section type as the first parameter and false as the second parameter.
    * @param {String} sectionid The ID of the section.
    * @param {String} sectiontype The type of the section ('Header', 'Footer', or other).
    * @returns value of the field based on their respective format.
    */
  displaysectionbasedontype(sectionid, sectiontype) {
    if (sectiontype == 'Header' || sectiontype == 'Footer') {
      var isnew = true;
      if (sectionid.indexOf('NotSaved') !== -1) {
        isnew = true;
      } else {
        isnew = false;
      }
      this.handlechildcomponents(sectiontype, isnew, sectionid);
    } else {
      this.handlechildcomponents(sectiontype, false, sectionid);
    }
  }

  /**
  * Method to give dynamic styling to element
  */
  get itemStyle() {
    return `background-color:${this.backgroundColor}; color: ${this.color}; padding:10px 10px 20px 10px; width:100%; box-shadow:0px 0px 2px rgb(229, 229, 229)`
  }

  /**
  * Method to prevent the default behavior of the action
  */
  preventDefault(event) {
    return event.preventDefault()
  }

  /**
  * Method to reset all the values on all the section components
  */
  @api resetallvaluesonAllcmp() {
    this.documenttemplaterecordid = '';
    this.doctemplatedetails.Id = '';
    this.doctemplatedetails.Name = '';
    this.doctemplatedetails.DxCPQ__Related_To_Type__c = '';
    this.relatedtoTypeObjChild = '',
    this.doctemplatedetails.DxCPQ__IsActive__c = false;
    this.doctemplatedetails.DxCPQ__Version_Number__c = '';
    this.doctemplatedetails.DxCPQ__Previously_Active__c = false;
    this.doctemplatedetails.DxCPQ__Parent_Template__c = '';
    this.showcontextdetails = false;
    this.showtabledetails = false;
    this.showrelatedobjectdetails = false;
    this.showheaderdetails = false;
    this.showfooterdetails = false;
    this.disableEditing = false;
    this.disableEditingHandler(this.disableEditing);
    this.readonlyVal = false;
    this.activateTemplateLabel = 'Activate Template';
    this.rowCount = -1;
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    this.header = { Id: 'headerNotSaved', Type: 'Header', rowCount: this.rowCount, sectionNameEntered: 'Header' };
    this.footer = { Id: 'footerNotSaved', Type: 'Footer', rowCount: this.rowCount, sectionNameEntered: 'Footer' };
    this.showPreview = false;
  }

  /**
  * Method to disable the preview option when made active
  */
  handlePreviewBackButton() {
    this.showTemplate = false;
    this.previewModal = true;
    this.previewRecordId = undefined;
  }
  
  /**
  * Method to disable the preview option when made active
  */
  get navigateToPreview() {
    return this.previewRecordId == undefined;
  }



  //--------------------------------DRAG FUNCTIONALITY START - VIVEK---------------------------------------------------------------
  sections = []; // Variable used to store the event value
  @api sectionMap; // Variable used to store the event value
  @api dragMap; // Variable used to store the event value
  optionsList = []; // Variable used to store the event value
  @track header = { Id: 'headerNotSaved', Type: 'Header', rowCount: this.rowCount, sectionNameEntered: 'Header' }; // Variable used to store the event value
  @track footer = { Id: 'footerNotSaved', Type: 'Footer', rowCount: this.rowCount, sectionNameEntered: 'Footer' }; // Variable used to store the event value


  connectedCallback() {
    getSFDomainBaseURL()
      .then(result => {
        console.log('domain base URL ----> ', result);
        this.baseURL = result;
      })
      .catch(error => {
        console.log('error while retrieving the org base URL --- > ', error);
      })
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    this.documenttemplaterecordid = this.recordId;
    this.doctemplatedetails.Id = this.recordId;
    if (this.isconnectedcalledonLoad == false || this.isconnectedcalledondeletion == true) {
      this.optionsList = [];
      this.isLoaded2 = true;
      this.firstsectionrecord = '';
      getAllDocumentTemplateSections({ docTempId: this.documenttemplaterecordid })
        .then(result => {
          if (result != null) {
            var headerselected = false;
            this.isconnectedcalledonLoad = true;
            this.footer.rowCount = result.length;
            result.forEach((val, index) => {
              if (val.DxCPQ__Type__c == 'Header') {
                headerselected = true;
                this.header.Id = val.Id;
                this.header.Type = val.DxCPQ__Type__c;
                this.header.rowCount = val.DxCPQ__Sequence__c;
                this.header.sectionNameEntered = val.Name;
              }
              else if (val.DxCPQ__Type__c == 'Footer') {
                this.footer.Id = val.Id;
                this.footer.Type = val.DxCPQ__Type__c;
                this.footer.rowCount = val.DxCPQ__Sequence__c;
                this.footer.sectionNameEntered = val.Name;
              }
              else {
                var indexposition;
                if (headerselected == true) { indexposition = 1; }
                else { indexposition = 0; }

                if (index == indexposition) {
                  this.firstsectionrecord = val;
                  this.doctemplatedetails.Name = val.DxCPQ__Document_Template__r.Name;
                  this.doctemplatedetails.Related_To_Type__c = val.DxCPQ__Document_Template__r.DxCPQ__Related_To_Type__c;
                  this.relatedtoTypeObjName = val.DxCPQ__Document_Template__r.DxCPQ__Related_To_Type__c;
                  this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
                  this.doctemplatedetails.DxCPQ__IsActive__c = val.DxCPQ__Document_Template__r.DxCPQ__IsActive__c;
                  this.doctemplatedetails.DxCPQ__Version_Number__c = val.DxCPQ__Document_Template__r.DxCPQ__Version_Number__c;
                  this.doctemplatedetails.DxCPQ__Parent_Template__c = val.DxCPQ__Document_Template__r.DxCPQ__Parent_Template__c;
                  if (this.doctemplatedetails.DxCPQ__IsActive__c == true) {
                    this.activateTemplateLabel = 'Deactivate Template';
                    this.showPreview = true;
                  }
                }
                this.rowCount = val.DxCPQ__Sequence__c;
                this.optionsList.push({ Id: val.Id, Type: val.DxCPQ__Type__c, rowCount: val.DxCPQ__Sequence__c, sectionNameEntered: val.Name });
              }
              this.disableEditing = val.DxCPQ__Document_Template__r.DxCPQ__Previously_Active__c;
              this.disableEditingHandler(this.disableEditing);
            });
            this.sections = this.optionsList;
            this.isLoaded2 = false;
            this.opensection = true;
            this.connectedCallbackHandler();
            if (this.firstsectionrecord) {
              this.displaysectionbasedontype(this.firstsectionrecord.Id, this.firstsectionrecord.DxCPQ__Type__c);
            }
          }

          // On load header section loading - by Rahul
          if (result.length < 1) {
            this.handlechildcomponents('Header', true, null);
            var _this = this;

            let sectionContainer = this.template.querySelector('[data-id="section menu"]');
            sectionContainer.innerHTML = '<span class="slds-form-element__label"> You can add sections to this template from here ➡️ &nbsp;</span>'

            let sectionItemContainer = this.template.querySelector('[data-id="section menu items"]');
            sectionItemContainer.style.border = '3px solid red';

            setTimeout(function () {
              const elm = _this.template.querySelector(`[data-id="headerNotSaved"]`);
              elm.classList.add("active");
            }, 1000);

            setTimeout(function () {
              _this.template.querySelector('[data-id="section menu"]').innerHTML = '';
              _this.template.querySelector('[data-id="section menu items"]').style.border = '0px solid transparent';
              _this.template.querySelector('[data-id="section menu items"]').style.transition = '1s';
            }, 2000);

          }
          else {
            let headerArray = result.filter((tempSection) => tempSection.DxCPQ__Type__c == 'Header');
            if (headerArray.length > 0) {
              this.handlechildcomponents('Header', false, headerArray[0].Id);
              setTimeout(() => {
                const elm = this.template.querySelector(`[data-onload="templateHeader"]`);
                elm.classList.add("active");
              }, 1000);
            }
            else {
              this.handlechildcomponents(result[0].DxCPQ__Type__c, false, result[0].Id);

              if (this.template.querySelector(`[data-onload="templateHeader"]`) != null) {
                const elm = this.template.querySelector(`[data-onload="templateHeader"]`);
                elm.classList.remove("active");
              }


              if (this.template.querySelector(`[data-onload="templateFooter"]`) != null) {
                const elm = this.template.querySelector(`[data-onload="templateFooter"]`);
                elm.classList.remove("active");
              }

              setTimeout(() => {
                const elm = this.template.querySelector(`[data-id="0"]`);
                elm.classList.add("active");
              }, 1000);
            }
          }
          // On load header section loading - by Rahul

        })
        .catch(error => {
          this.isLoaded2 = false;
            let tempError = error.toString();
            let errorMessage = error.message || 'Unknown error message';
            createLog({recordId:'', className:'templateDesignerCMP LWC Component - connectedCallback()', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
        })
    } else if (this.isconnectedcalledonLoad == true) {
      this.sections = this.optionsList;
      this.connectedCallbackHandler();
      var _this = this;

      setTimeout(() => {

        const elm_ = this.template.querySelector(`[data-onload="templateHeader"]`);
        elm_.classList.remove("active");

        const elm = this.template.querySelector(`[data-onload="templateFooter"]`);
        elm.classList.remove("active");

        this.sections.forEach((loopvar, index) => {
          const elm0 = this.template.querySelector(`[data-id="${index}"]`);
          elm0.classList.remove("active");
        });

        const newSectionAdded = (element) => element.Id == _this.selectedSectionRecordID;
        let newSectionIndex = this.optionsList.findLastIndex(newSectionAdded);
        const elm1 = this.template.querySelector(`[data-id="${newSectionIndex}"]`);
        elm1.classList.add("active");
      }, 2000)

    }
  }

  /**
  * Method to update the section variable 
  */
  connectedCallbackHandler() {
    if (!!this.sections) {
      this.sectionMap = new Map();
      let tempArray = JSON.parse(JSON.stringify(this.sections));
      tempArray.forEach((arrayElement, index) => {
        arrayElement.index = index;
        arrayElement.rowCount = index + 1;
        this.sectionMap.set(arrayElement.Id, arrayElement);
      });
      this.sections = JSON.parse(JSON.stringify(tempArray));
    }
  }

  /**
  * Method to active the template selected 
  */
  handleActiveTemplate() {
    let isActive;
    if (this.activateTemplateLabel == 'Activate Template') {
      this.activateTemplateLabel = 'Deactivate Template';
      isActive = true;
    } else {
      this.activateTemplateLabel = 'Activate Template';
      isActive = false;
    }
    if (this.disableEditing == false) {
      this.template.querySelector("c-template-content-details").handleObjectNameSelection(this.relatedtoTypeObjName);
      this.template.querySelector("c-template-related-objects").handleObjectNameSelection(this.relatedtoTypeObjName);
      this.template.querySelector('c-template-content-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-table-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-related-objects').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-header').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-footer').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    }
    activateTemplate({ templateId: this.documenttemplaterecordid, parentId: this.doctemplatedetails.DxCPQ__Parent_Template__c, isActive: isActive }).then(result => {
      if (result != null) {
        this.disableEditing = result.DxCPQ__Previously_Active__c;
      }
    }).catch(error => {
      console.log('error activation', error);
    })
  }

  /**
  * Method to disable editing for the all sections under the selected template when the template is made active
  */
  disableEditingHandler(isActive) {
    this.template.querySelector('c-template-content-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-table-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-related-objects').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-header').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-footer').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.readonlyVal = isActive? true: false;
  }

  /**
  * Method to open the clone popup and show the cloned template
  */
  handleCloneTemplate() {
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showwatermarkbtn = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = true;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

  /**
  * Method to show the preview of the template for the selected record ID
  */
  showpreviewtemplate() {
    this.previewModal = false;
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showwatermarkbtn = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = false;
    this.showTemplate = true;
    this.template.querySelector('c-modal').show();
  }

 /**
  * Method to open the preview modal to select the record ID for previewing the selected template
  */
  handlePreview() {
    this.previewLabel = `Search a ${this.relatedtoTypeObjName} for this template to preview`;
    if (this.relatedtoTypeObjName.toLowerCase().startsWith("a") || this.relatedtoTypeObjName.toLowerCase().startsWith("e") ||
      this.relatedtoTypeObjName.toLowerCase().startsWith("i") || this.relatedtoTypeObjName.toLowerCase().startsWith("o") || this.relatedtoTypeObjName.toLowerCase().startsWith("a") || this.relatedtoTypeObjName.toLowerCase().startsWith("u")) {
      this.previewLabel = `Search an ${this.relatedtoTypeObjName} for this template to preview`;
    }
    this.previewModal = true;
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showwatermarkbtn = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

 /**
  * Method to open the edit template screen. It also triggers the getSavedDocTempWatermarkData() to get the information of the watermark if saved any on this selected template
  */
  handleEditTemplate() {
    this.showAddNewTemplate = false;
    this.showCloneTemplate = false;
    this.showDeleteTemplate = false;
    this.editTemplate = true;
    this.showwatermarkbtn = false;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
    this.template.querySelector('c-template-related-objects').clearChildObjSelection();
    this.getSavedDocTempWatermarkData();
  }

  /**
  * Method to close the preview modal screen
  */
  closePreviewModal() {
    this.showCloneTemplate = false;
    this.editTemplate = false;
    this.showwatermarkbtn = false;
    this.showAddNewTemplate = false;
    this.showDeleteTemplate = false;
    this.previewModal = false;
    this.showTemplate = false;
    this.previewRecordId = undefined;
    this.template.querySelector('c-modal').hide();
  }

  /**
  * Method to show the delete template popup
  */
  handleDeleteTemplateHandler() {
    this.showCloneTemplate = false;
    this.editTemplate = false;
    this.showwatermarkbtn = false;
    this.showAddNewTemplate = false;
    this.showDeleteTemplate = true;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

  /**
  * Method to refresh the selected template
  */
  handleRefreshTemplateHandler() {
    setTimeout(() => {
      eval("$A.get('e.force:refreshView').fire();");
    }, 100);
  }

  /**
  * Method to select the record ID to preview the template for that record ID
  * @param {Object} event
  */
  selectItemEventHandler(event) {
    this.previewRecordId = event.detail.selectedRecord.recordId;
    this.templateId = this.doctemplatedetails.Id;
    this.templatename = this.doctemplatedetails.Name;
  }

  /**
  * Method to update the value of previewRecordId when the selected Record ID is removed
  * @param {Object} event
  */
  updateItemEventHandler() {
    this.previewRecordId = undefined;
  }

  /**
  * Method to edit the saved document template information 
  * @param {Object} event
  */
  handleEditSuccess(event) {
    const toastEvt = new ShowToastEvent({
      title: 'Success',
      message: 'Template "' + event.detail.fields.Name.value + '"' + this.popUpMessage.TEMPLATE_DESIGN_UPDATED,//'Edited Successfully',
      variant: 'Success',
    });
    this.dispatchEvent(toastEvt);
    let createdDocumentTemplateId = event.detail.id;
    let name = event.detail.fields.Name.value;
    let versionno = event.detail.fields.DxCPQ__Version_Number__c.value;
    const newDocTempEvt = new CustomEvent('docedited', {
      detail: { id: createdDocumentTemplateId, name: name, version: versionno }, bubbles: true
    });
    this.dispatchEvent(newDocTempEvt);
    this.template.querySelector('c-modal').hide();
  }

  /**
  * Method to clone the existing template in to a new template with the same data as that of the exiting one
  * @param {Object} event
  */
  cloneTemplateHandler(event) {
    const newDocTempEvt = new CustomEvent('doccreated', {
      detail: { id: event.detail.id, name: event.detail.name, templateObj: event.detail.templateObj }, bubbles: true
    });
    this.dispatchEvent(newDocTempEvt);
    const toastEvt = new ShowToastEvent({
      title: 'Success',
      message: 'Created Successfully',
      variant: 'Success',
    });
    this.dispatchEvent(toastEvt);
    this.template.querySelector('c-modal').hide();
  }

  /**
  * Method called to cancel the delete the document template action when delete template pop up opens
  */
  cancelDeleteHandler() {
    this.template.querySelector('c-modal').hide();
  }

  /**
  * Method called to delete the document template
  */
  permanantDeleteHandler() {
    deleteTemplate({ templateId: this.documenttemplaterecordid }).then(result => {
      console.log('successful', result);
      const toastEvt = new ShowToastEvent({
        title: 'Success',
        message: 'Template ' + this.popUpMessage.TEMPLATE_DESIGN_DELETED,//'Deleted Successfully',
        variant: 'Success',
      });
      this.dispatchEvent(toastEvt);
      const delEvt = new CustomEvent('deletetemplate', {
        detail: { id: this.documenttemplaterecordid }, bubbles: true
      });
      this.dispatchEvent(delEvt);
      this.template.querySelector('c-modal').hide();
    }).catch(error => {
      console.log('error handleDeleteTemplateHandler', JSON.stringify(error));
        let tempError = error.toString();
        let errorMessage = error.message || 'Unknown error message';
        createLog({recordId:'', className:'templateDesignerCMP LWC Component - permanantDeleteHandler()', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
    })
  }

  renderedCallback() {
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    Promise.all([
      loadStyle(this, dxQuoteTemplate + '/dxQuoteTemplate.css'),
      loadStyle(this, dexcpqcartstylesCSS),
    ])
      .then(() => { })
      .catch(error => { console.log(error.body.message); });
  }

  /**
  * Method called to save the document template sections in the same sequence they are arranged on the UI
  */
  handleSubmit() {
    var allRecords = [];
    this.sections.forEach(function (val) {
      var Recorddetails = { Name: '', DxCPQ__Sequence__c: 0, DxCPQ__Type__c: '', Id: '' };
      Recorddetails.Id = val.Id;
      Recorddetails.Name = val.sectionNameEntered;
      Recorddetails.DxCPQ__Sequence__c = val.index;
      Recorddetails.DxCPQ__Type__c = val.Name;
      allRecords.push(Recorddetails);
    });
    this.isLoaded = true;
    saveDocumentTemplateSectionSequences({ allSectionRecords: allRecords })
      .then(result => {
        if (result != null) { this.isLoaded = false; }
      })
      .catch(error => { 
        this.isLoaded = false; 
        let tempError = error.toString();
        let errorMessage = error.message || 'Unknown error message';
        createLog({recordId:'', className:'templateDesignerCMP LWC Component - handleSubmit()', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
      })
  }

  /**
  * Method assigns the Sections sequence after the drag and drop action is completed
  */
  processRowNumbers() {
    const trs = this.template.querySelectorAll(".myIndex");
    const ids = this.template.querySelectorAll(".myId");
    for (let i = 0; i < trs.length; i++) {
      let currentRowId = ids[i].innerText;
      let currentRowRef = this.sectionMap.get(currentRowId);
      currentRowRef.index = i;
      currentRowRef.rowCount = i + 1;
      this.sectionMap.set(currentRowId, currentRowRef);
      trs[i].innerText = i;
    }
    this.sections = Array.from(this.sectionMap.values());
    this.handleSubmit();
  }
   /**
  * Method called when the onDragStart action is performed, this method assigns the necessary attributes to the event evt
  * @param {Object} evt
  */
  onDragStart(evt) {
    console.log('onDragStart');
    this.dragMap = new Map();
    let eventRowDataId = evt.currentTarget.dataset.dragId;
    evt.dataTransfer.setData("dragId", eventRowDataId);
    evt.dataTransfer.setData("sy", evt.pageY);
    evt.dataTransfer.effectAllowed = "move";
    evt.currentTarget.classList.add("grabbed");
    if (this.dragMap.has(eventRowDataId)) {
      this.dragMap.forEach((value) => value.classList.add("grabbed"));
    }
  }
  /**
  * Method called when the dragOver action is performed, this method assigns the dropEffect
  * @param {Object} evt
  */
  onDragOver(evt) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
  }

  /**
  * Method to restack the created sections in a document template
  * @param {Object} evt
  */
  onDrop(evt) {
    evt.preventDefault();
    let sourceId = evt.dataTransfer.getData("dragId");
    const sy = evt.dataTransfer.getData("sy");
    const cy = evt.pageY;

    if (sy > cy) {
      if (this.dragMap.has(sourceId)) {
        Array.from(this.dragMap).reverse().forEach(element => {
          let key = element[0];
          const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
          if (!!elm) {
            elm.classList.remove("grabbed");
          }
          evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
        });
      } else {
        const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
        if (!!elm) {
          elm.classList.remove("grabbed");
        }
        evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
      }
    } else {
      if (this.dragMap.has(sourceId)) {
        this.dragMap.forEach((key) => {
          const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
          if (!!elm) {
            elm.classList.remove("grabbed");
          }
          evt.currentTarget.parentElement.insertBefore(
            elm,
            evt.currentTarget.nextElementSibling
          );
        });
      } else {
        const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
        if (!!elm) {
          elm.classList.remove("grabbed");
        }
        evt.currentTarget.parentElement.insertBefore(
          elm,
          evt.currentTarget.nextElementSibling
        );
      }
    }
    this.processRowNumbers();
  }



  //code added by Bhavya for Watermark
    /**
    * Method to display the Watermark Screen when "Watermark Settings" button is clicked on Edit Screen
    */
  handleWatermarkSettings() {
    this.editTemplate = false;
    this.showwatermarkbtn = true;
    this.getSavedDocTempWatermarkData();
    //this.generateCanvas();
  }

/**
    * Method to store the user inputs for different inputs used for creating a watermark on Canvas
    * This method is used storing the variable related to both Text and Image Watermarks
    * Based on the user inputs and the activeTab value the respective draw on canvas methods are called to create a image watermark for the user given inputs
    * @param {Object} event
    */
  handleWatermarkChange(event) {
    const fieldName = event.target.dataset.label;
    const value = event.target.value;
    const fieldMap = {
      watermarkText: 'watermarkText',
      color: 'colorValue',
      fontSize: 'fontSizeValue',
      alignment: 'alignmentValue',
      direction: 'directionValue',
      rotation: 'rotationValue',
      opacity: 'opacityValue',
      autofit: 'autofit',
      imagescaling: 'imageScalingValue',
      textPrimary: "checkedValText",
      imagePrimary: "checkedValImage",
      opacityImage: "opacityImageValue"
    };

    if (fieldMap[fieldName]) {
      this[fieldMap[fieldName]] = value;
    }
    console.log('fieldMap after assigning >> ', fieldMap);
    if (this.activeTab == 'Text') {
      this.generateCanvas();
    }
    else {
      this.drawOnCanvas(this.imageUrl);
    }
  }

  /**
    * Method to store the clicked tab name in the variable called "activeTab"
    * @param {Object} event
    */
  handleTabChange(event) {
    this.activeTab = event.currentTarget.dataset.name;
    console.log('Tab clicked:', this.activeTab);
  }

  /**
    * Method to create the image of the text watermark for the given user inputs
    * @param {Object} event
    */
  generateCanvas() {
    const canvas = this.template.querySelector('canvas');
    const context = canvas.getContext('2d');
    context.clearRect(0, 0, canvas.width, canvas.height);
    if (this.rotationValue !== this.previousRotationValue) {
      context.translate(canvas.width / 2, canvas.height / 2);
      context.rotate((this.rotationValue - this.previousRotationValue) * Math.PI / 180);
      context.translate(-canvas.width / 2, -canvas.height / 2);
      this.previousRotationValue = this.rotationValue;
    }
    context.globalAlpha = this.opacityValue;
    context.font = this.fontSizeValue + 'px Arial';
    let textWidth = context.measureText(this.watermarkText).width;
    context.fillStyle = this.colorValue;
    context.fillText(this.watermarkText, (canvas.width/2 - textWidth/2), canvas.height / 2);
  }

    /**
    * Method to handle rotation values for Text and Image Watermarks seperately
    * Once the rotation values are captured then the respective canvas drawing methods are called to update the final output for the captured rotation values
    * @param {Object} event
    */
  handleRotationChange(event) {
    console.log('rotation val >> ', event.target.value);
    let slectedRotation = event.currentTarget.dataset.type;
    if (slectedRotation == 'Text') {
      this.rotationValue = event.target.value;
      this.outerDabba = `transform: rotate(${this.rotationValue}deg);`;
      this.generateCanvas();
    }
    else if (slectedRotation == 'Image') {
      this.rotationImagevalue = event.target.value;
      this.outerDabba = `transform: rotate(${this.rotationImagevalue}deg);`;
      this.drawOnCanvas(this.imageUrl);
    }
  }

   /**
    * Method to save the created Text & Image watermarks for the user given inputs
    * Once the images drawn in both cases - text & image are saved then their contentversion IDs are captured and using the updateRecord the Watermark_Data__c field on Document_Template__c object is updated based on the selected ID
    */
  handleWaterMarkSave() {
    console.log('handleWaterMarkSave saved >> ');
    let baseDataLst = [];
    let canvasText = this.template.querySelector('.canvasText');
    if (canvasText && this.watermarkText !== '') {
      let dataURLText = canvasText.toDataURL();
      baseDataLst.push({ 'text': dataURLText.split(',')[1], title:'Text' });
    }

    let canvasImage = this.template.querySelector('.canvasImage');
    if (canvasImage && this.imageUrl) {
      let dataURLImage = canvasImage.toDataURL();
      baseDataLst.push({ 'Image': dataURLImage.split(',')[1], title:'Image' });
    }

    console.log('Canvas Data URL baseDataLst inside handleSave ---- > ', baseDataLst);
    this.showwatermarkbtn = false;
    saveContentVersion({ title: "WatermarkImage", base64DataList: baseDataLst, templateId: this.documenttemplaterecordid })
      .then(result => {
        console.log('File saved successfully returned ContentVersion ID :', result);
        this.imageSavedId = result;
        const fields = {};
       let watermarkText = (result.filter(obj => Object.keys(obj).some(key => key.includes('Text'))) || [])[0];
       let watermarkImage = (result.filter(obj => Object.keys(obj).some(key => key.includes('Image'))) || [])[0];
       watermarkText = watermarkText ? watermarkText[Object.keys(watermarkText)[0]] : null;
       watermarkImage = watermarkImage? watermarkImage[Object.keys(watermarkImage)[0]] : null;

        const watermarkImageIdText = {
          name: 'Text',
          isPrimary: this.checkedValText,
          contentVersionID: watermarkText,
          pageOption: this.pageTextOption,
          fontsize: this.fontSizeValue,
          opacity: this.opacityValue,
          color: this.colorValue,
          rotation: this.rotationValue,
          textVal: this.watermarkText,
          pageTextOption: this.pageTextOption

        };

        const watermarkImageIdImage = {
          name: 'Image',
          isPrimary: this.checkedValImage,
          contentVersionID: watermarkImage,
          pageOption: this.pageImageOption,
          opacity: this.opacityImageValue,
          rotation: this.rotationImagevalue,
          pageImageOption: this.pageImageOption,
          imageScale: this.imageScalingValue
        };
        fields[DOCUMENTTEMPLATEID_FIELD.fieldApiName] = this.documenttemplaterecordid;
        let jsonDataLst = [watermarkImageIdText, watermarkImageIdImage];
        fields[WATERMARKDATA_FIELD.fieldApiName] = JSON.stringify(jsonDataLst);
        const recordInput = { fields };
        console.log('recordInput to update >> ', recordInput);
        updateRecord(recordInput)
          .then(() => {
              const toastEvt = new ShowToastEvent({
                  title: 'Success!',
                  message: 'Watermark saved successfully',
                  variant: 'Success',
              });
              this.dispatchEvent(toastEvt);
              this.showwatermarkbtn = false;
              this.template.querySelector('c-modal').hide();
          })
          .catch(error => {
              const toastEvt = new ShowToastEvent({
                  title: 'Error!',
                  message: 'Cannot save watermark Image',
                  variant: 'error',
              });
              this.dispatchEvent(toastEvt);
              this.showwatermarkbtn = false;
              this.template.querySelector('c-modal').hide();
          });
      })
      .catch(error => {
        console.error('Error saving file:', error);
      });
  }

  /**
  * Method to hide the Watermark Screen from UI
  */
  handleWaterMarkCancel() {
    console.log('handleWaterMarkCancel clicked >> ');
    this.showwatermarkbtn = false;
    this.editTemplate = true;
  }

  /**
  * Method to catch the data of the uploaded image files 
  * @param {Object} event
  */
  handleUploadFinished(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      this.imageUrl = reader.result;
      this.drawOnCanvas(this.imageUrl);
    };
    reader.readAsDataURL(file);
  }

  /**
  * Method to create the image of the Image watermark for the given user inputs
  * @param {Object} imageUrl
  */
  drawOnCanvas(imageUrl) {
    const canvas = this.template.querySelector('.canvasImage');
    const ctx = canvas.getContext('2d');
    const image = new Image();
    image.src = imageUrl;
    image.onload = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      if (this.rotationImagevalue !== this.previousImgRotationValue) {
        ctx.translate(canvas.width / 2, canvas.height / 2);
        ctx.rotate((this.rotationImagevalue - this.previousImgRotationValue) * Math.PI / 180);
        ctx.translate(-canvas.width / 2, -canvas.height / 2);
        this.previousImgRotationValue = this.rotationImagevalue;
      }
      ctx.globalAlpha = this.opacityImageValue;
      let imgwidth = this.imageScalingValue == 0 ? image.width : image.width * (this.imageScalingValue / 100);
      let imgheight = this.imageScalingValue == 0 ? image.height : image.height * (this.imageScalingValue / 100);
      ctx.drawImage(image, (canvas.width - imgwidth) / 2, (canvas.height - imgheight) / 2, this.imageScalingValue == 0 ? image.width : image.width * (this.imageScalingValue / 100), this.imageScalingValue == 0 ? image.height : image.height * (this.imageScalingValue / 100));
      //ctx.drawImage(image, canvas.width/3, canvas.height/3, this.imageScalingValue == 0 ? image.width : image.width * (this.imageScalingValue / 100), this.imageScalingValue == 0 ? image.height : image.height * (this.imageScalingValue / 100));
      console.log('canvas---', (canvas.width / 2 - imgwidth), '__', (canvas.height / 3 - imgheight), '__', this.imageScalingValue == 0 ? image.width : image.width * (this.imageScalingValue / 100), '__', this.imageScalingValue == 0 ? image.height : image.height * (this.imageScalingValue / 100))
      //const dataURL = canvas.toDataURL();
      //console.log('Data URL for Image Watermark ----> ', dataURL);
    };
  }
    /**
    * Method to store the Watermark Page Option i.e., on what pages the watermark should be visible is handled with the following method
    * @param {Object} event
    */  
  handleWatermarkPageChange(event) {
    if (this.activeTab == "Text") {
      this.pageTextOption = event.target.value;
    }
    else if (this.activeTab == "Image") {
      this.pageImageOption = event.target.value;
    }
  }

  /**
  * Method to store the information about which type of watermark should be used for displaying on the final PDF
  * By Default, the text watermark is made primary with option show on "All Pages"
  * @param {Object} event
  */
  handleWatermarkPrimary(event) {
    const isChecked = event.target.checked;
    if (this.activeTab === "Text") {
      this.checkedValText = isChecked;
      this.checkedValImage = !this.checkedValText;
    } else if (this.activeTab === "Image") {
      this.checkedValImage = isChecked;
      this.checkedValText = !this.checkedValImage;
    }
  }

  /**
  * Method to get the already saved watermark data from apex and assign them to the respective variables
  */
  getSavedDocTempWatermarkData() {
    try{
      getDocumentTemplateData({ templateId: this.recordId }).then(result => {
        if (result != null) {
          console.log('printing document template details --- > ', result);
          let savedWaterMarkData = JSON.parse(result.DxCPQ__Watermark_Data__c);
          this.fontSizeValue = savedWaterMarkData[0].fontsize;
          this.opacityValue = savedWaterMarkData[0].opacity;
          this.checkedValText = savedWaterMarkData[0].isPrimary;
          this.pageTextOption = savedWaterMarkData[0].pageTextOption;
          this.watermarkText = savedWaterMarkData[0].textVal;
          this.colorValue = savedWaterMarkData[0].color;
          this.rotationValue = savedWaterMarkData[0].rotation;
          this.rotationImagevalue = savedWaterMarkData[1].rotation;
          this.imageScalingValue = savedWaterMarkData[1].imageScale;
          this.pageImageOption = savedWaterMarkData[1].pageImageOption;
          this.checkedValImage = savedWaterMarkData[1].isPrimary;
          this.opacityImageValue = savedWaterMarkData[1].opacity;
          this.generateCanvas();
        }
      }).catch(error => {
        console.log('error activation', error);
      })
    } catch(error) {
      console.log('error' + error);
    }
  }
}