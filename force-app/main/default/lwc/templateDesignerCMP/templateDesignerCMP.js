import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveDocumentTemplateSectionSequences from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionSequences';
import getAllDocumentTemplateSections from '@salesforce/apex/SaveDocumentTemplatesection.getAllDocumentTemplateSections';
import activateTemplate from '@salesforce/apex/SaveDocumentTemplate.activateTemplate';
import deleteTemplate from '@salesforce/apex/SaveDocumentTemplate.deleteTemplate';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import dxQuoteTemplate from '@salesforce/resourceUrl/dxQuoteTemplate';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';

export default class TemplateDesignerCMP extends NavigationMixin(LightningElement) {
  @api recordId;
  value = '';
  rowCount = -1;
  selectedOption;
  isLoaded = false;
  SectionTypename;
  recordidtoedit = '';
  firstsectionrecord;
  editTemplate = false;
  opensection = false;
  disableEditing = false;
  showtabledetails = false;
  showclausescreen = false;
  showheaderdetails = false;
  showfooterdetails = false;
  showCloneTemplate = false;
  showAddNewTemplate = false;
  showDeleteTemplate = false;
  documenttemplaterecordid;
  showcontextdetails = false;
  selectedSectionRecordID = '';
  isconnectedcalledonLoad = false;
  showrelatedobjectdetails = false;
  activateTemplateLabel = 'Activate Template';
  @track showPreview = false;
  @track previewModal = false;
  previewLabel = '';
  @track showTemplate = false;
  isconnectedcalledondeletion = false;
  previewRecordId;
  templateId;
  templatename;
  @api relatedtoTypeObjName;
  @track relatedtoTypeObjChild;
  quoteName;
  popUpMessage;

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
    Dx_Temp__Related_To_Type__c: '',
    Dx_Temp__IsActive__c: false,
    Dx_Temp__Version_Number__c: '', Dx_Temp__Previously_Active__c: false, Dx_Temp__Parent_Template__c: ''
  };

  constructor() {
    super();
  }

  @api handleConnectedCallback(doc) {
    this.recordId = doc.Id;
    this.doctemplatedetails.Id = doc.Id;
    this.doctemplatedetails.Dx_Temp__Related_To_Type__c = doc.Dx_Temp__Related_To_Type__c;
    this.relatedtoTypeObjName = doc.Dx_Temp__Related_To_Type__c;
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    this.isconnectedcalledonLoad = false;
    this.connectedCallback();
  }

  @api passingObject(objName) {
    this.relatedtoTypeObjChild = objName;
    this.template.querySelector("c-template-content-details").handleObjectNameSelection(this.relatedtoTypeObjName);
    this.template.querySelector("c-template-related-objects").handleObjectNameSelection(this.relatedtoTypeObjName);
    /* Commented by Rahul -> Merge Fields in Header and Footer */
    // this.template.querySelector("c-template-footer-type").handleObjectNameSelection(this.relatedtoTypeObjName);
    // this.template.querySelector("c-template-header-type").handleObjectNameSelection(this.relatedtoTypeObjName);
  }

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
      //this.isModalOpen = false;
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
      //this.isModalOpen = false;
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
    // Commented by Rahul - Template Table Details not considered in this release.
    /*else if (selectedOption == 'Table') {
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
    }*/
    else if (selectedOption == 'Header') {
      this.showclausescreen = false;
      this.showtabledetails = false;
      this.showrelatedobjectdetails = false;
      this.SectionTypename = 'Header';
      console.log('Option selected with value: ' + selectedOption);
      this.opensection = true;
      //this.isModalOpen = false;
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

  /*handleSelectedValue(event) {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    const selectedOption = event.detail.value;
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }*/

  handleNewContext() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    const selectedOption = 'Context';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }

  handleNewRelatedObjects() {
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-related-objects").resetvaluesonchildcmp();
    this.template.querySelector("c-template-related-objects").assignDocTempId(this.doctemplatedetails.Id);
    const selectedOption = 'Related Objects';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }

  handleNewClause() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    const selectedOption = 'Clause';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }

  /*handleNewTable() {
    this.selectedSectionRecordID = '';
    this.template.querySelector("c-template-table-details").resetvaluesonchildcmp();
    const selectedOption = 'Table';
    this.isconnectedcalledondeletion = false;
    this.handlechildcomponents(selectedOption, true, null);
  }*/

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

  handlesavedheaderdata(event) {
    this.header.Id = event.detail.Id;
    if (this.showPreview == false) { this.showPreview = true; }
  }

  handlesavedfooterdata(event) {
    this.footer.Id = event.detail.Id;
    if (this.showPreview == false) { this.showPreview = true; }
  }

  handledeletesectiondata(event) {
    this.isconnectedcalledondeletion = true;
    this.connectedCallback();
  }

  handleHeaderClick(event) {
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

  handleFooterClick(event) {
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

  get itemStyle() {
    return `background-color:${this.backgroundColor}; color: ${this.color}; padding:10px 10px 20px 10px; width:100%; box-shadow:0px 0px 2px rgb(229, 229, 229)`
  }

  preventDefault(event) {
    return event.preventDefault()
  }

  @api resetallvaluesonAllcmp() {
    this.documenttemplaterecordid = '';
    this.doctemplatedetails.Id = '';
    this.doctemplatedetails.Name = '';
    this.doctemplatedetails.Dx_Temp__Related_To_Type__c = '';
    this.relatedtoTypeObjChild = '',
      this.doctemplatedetails.Dx_Temp__IsActive__c = false;
    this.doctemplatedetails.Dx_Temp__Version_Number__c = '';
    this.doctemplatedetails.Dx_Temp__Previously_Active__c = false;
    this.doctemplatedetails.Dx_Temp__Parent_Template__c = '';
    this.showcontextdetails = false;
    this.showtabledetails = false;
    this.showrelatedobjectdetails = false;
    this.showheaderdetails = false;
    this.showfooterdetails = false;
    this.disableEditing = false;
    this.disableEditingHandler(this.disableEditing);
    this.activateTemplateLabel = 'Activate Template';
    this.rowCount = -1;
    this.template.querySelector("c-template-content-details").resetvaluesonchildcmp();
    this.header = { Id: 'headerNotSaved', Type: 'Header', rowCount: this.rowCount, sectionNameEntered: 'Header' };
    this.footer = { Id: 'footerNotSaved', Type: 'Footer', rowCount: this.rowCount, sectionNameEntered: 'Footer' };
    this.showPreview = false;
  }

  handlePreviewBackButton(){
    this.showTemplate = false;
    this.previewModal = true;
    this.previewRecordId = undefined;
  }

  get navigateToPreview(){
    return this.previewRecordId==undefined;
  }



  //--------------------------------DRAG FUNCTIONALITY START - VIVEK---------------------------------------------------------------
  sections = [];

  @api sectionMap;
  @api dragMap;
  optionsList = [];
  @track header = { Id: 'headerNotSaved', Type: 'Header', rowCount: this.rowCount, sectionNameEntered: 'Header' };
  @track footer = { Id: 'footerNotSaved', Type: 'Footer', rowCount: this.rowCount, sectionNameEntered: 'Footer' };

  connectedCallback() {
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
              if (val.Dx_Temp__Type__c == 'Header') {
                headerselected = true;
                this.header.Id = val.Id;
                this.header.Type = val.Dx_Temp__Type__c;
                this.header.rowCount = val.Dx_Temp__Sequence__c;
                this.header.sectionNameEntered = val.Name;
              }
              else if (val.Dx_Temp__Type__c == 'Footer') {
                this.footer.Id = val.Id;
                this.footer.Type = val.Dx_Temp__Type__c;
                this.footer.rowCount = val.Dx_Temp__Sequence__c;
                this.footer.sectionNameEntered = val.Name;
              }
              else {
                var indexposition;
                if (headerselected == true) { indexposition = 1; }
                else { indexposition = 0; }

                if (index == indexposition) {
                  this.firstsectionrecord = val;
                  this.doctemplatedetails.Name = val.Dx_Temp__Document_Template__r.Name;
                  this.doctemplatedetails.Related_To_Type__c = val.Dx_Temp__Document_Template__r.Dx_Temp__Related_To_Type__c;
                  this.relatedtoTypeObjName = val.Dx_Temp__Document_Template__r.Dx_Temp__Related_To_Type__c;
                  this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
                  this.doctemplatedetails.Dx_Temp__IsActive__c = val.Dx_Temp__Document_Template__r.Dx_Temp__IsActive__c;
                  this.doctemplatedetails.Dx_Temp__Version_Number__c = val.Dx_Temp__Document_Template__r.Dx_Temp__Version_Number__c;
                  this.doctemplatedetails.Dx_Temp__Parent_Template__c = val.Dx_Temp__Document_Template__r.Dx_Temp__Parent_Template__c;
                  if (this.doctemplatedetails.Dx_Temp__IsActive__c == true) {
                    this.activateTemplateLabel = 'Deactivate Template';
                    this.showPreview = true;
                  }
                }
                this.rowCount = val.Dx_Temp__Sequence__c;
                this.optionsList.push({ Id: val.Id, Type: val.Dx_Temp__Type__c, rowCount: val.Dx_Temp__Sequence__c, sectionNameEntered: val.Name });
              }
              this.disableEditing = val.Dx_Temp__Document_Template__r.Dx_Temp__Previously_Active__c;
              this.disableEditingHandler(this.disableEditing);
            });
            this.sections = this.optionsList;
            this.isLoaded2 = false;
            this.opensection = true;
            this.connectedCallbackHandler();
            if (this.firstsectionrecord) {
              this.displaysectionbasedontype(this.firstsectionrecord.Id, this.firstsectionrecord.Dx_Temp__Type__c);
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
            let headerArray = result.filter((tempSection) => tempSection.Dx_Temp__Type__c == 'Header');
            if (headerArray.length > 0) {
              this.handlechildcomponents('Header', false, headerArray[0].Id);
              setTimeout(() => {
                const elm = this.template.querySelector(`[data-onload="templateHeader"]`);
                elm.classList.add("active");
              }, 1000);
            }
            else {
              this.handlechildcomponents(result[0].Dx_Temp__Type__c, false, result[0].Id);

              if(this.template.querySelector(`[data-onload="templateHeader"]`) != null) {
                const elm = this.template.querySelector(`[data-onload="templateHeader"]`);
                elm.classList.remove("active");
              }

              
              if(this.template.querySelector(`[data-onload="templateFooter"]`) != null) {
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

  connectedCallbackHandler() {
    console.log('connectedCallbackHandler');
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

  handleActiveTemplate(event) {
    let isActive;

    if (this.activateTemplateLabel == 'Activate Template') {
      this.activateTemplateLabel = 'Deactivate Template';
      isActive = true;
    } else {
      this.activateTemplateLabel = 'Activate Template';
      isActive = false;
      //this.template.querySelector("c-template-header").loadsectionsvaluesforCreation();
    }

    if (this.disableEditing == false) {
      this.template.querySelector("c-template-content-details").handleObjectNameSelection(this.relatedtoTypeObjName);
      this.template.querySelector("c-template-related-objects").handleObjectNameSelection(this.relatedtoTypeObjName);

      // this.template.querySelector("c-template-footer-type").handleObjectNameSelection(this.relatedtoTypeObjName);
      // this.template.querySelector("c-template-header-type").handleObjectNameSelection(this.relatedtoTypeObjName);

      this.template.querySelector('c-template-content-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      //this.template.querySelector('c-template-table-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-related-objects').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-header').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
      this.template.querySelector('c-template-footer').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    }

    activateTemplate({ templateId: this.documenttemplaterecordid, parentId: this.doctemplatedetails.Dx_Temp__Parent_Template__c, isActive: isActive }).then(result => {
      if (result != null) {
        this.disableEditing = result.Dx_Temp__Previously_Active__c;
      }
    }).catch(error => {
      console.log('error activation', error);
    })
  }

  disableEditingHandler(isActive) {
    this.template.querySelector('c-template-content-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    //this.template.querySelector('c-template-table-details').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-related-objects').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-header').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
    this.template.querySelector('c-template-footer').handleActivateTemplate(isActive, this.relatedtoTypeObjName);
  }

  handleCloneTemplate(event) {
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = true;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

  showpreviewtemplate() {
    this.previewModal = false;
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = false;
    this.showTemplate = true;
    this.template.querySelector('c-modal').show();
  }

  handlePreview() {
    this.previewLabel = `Search a ${this.relatedtoTypeObjName} for this template to preview`;
    if (this.relatedtoTypeObjName.toLowerCase().startsWith("a") || this.relatedtoTypeObjName.toLowerCase().startsWith("e") ||
      this.relatedtoTypeObjName.toLowerCase().startsWith("i") || this.relatedtoTypeObjName.toLowerCase().startsWith("o") || this.relatedtoTypeObjName.toLowerCase().startsWith("a") || this.relatedtoTypeObjName.toLowerCase().startsWith("u")) {
      this.previewLabel = `Search an ${this.relatedtoTypeObjName} for this template to preview`;
    }
    this.previewModal = true;
    this.showAddNewTemplate = false;
    this.editTemplate = false;
    this.showDeleteTemplate = false;
    this.showCloneTemplate = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

  //edits the template
  handleEditTemplate() {
    this.showAddNewTemplate = false;
    this.showCloneTemplate = false;
    this.showDeleteTemplate = false;
    this.editTemplate = true;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
    this.template.querySelector('c-template-related-objects').clearChildObjSelection();
  }

  closePreviewModal() {
    this.showCloneTemplate = false;
    this.editTemplate = false;
    this.showAddNewTemplate = false;
    this.showDeleteTemplate = false;
    this.previewModal = false;
    this.showTemplate = false;
    this.previewRecordId = undefined;
    this.template.querySelector('c-modal').hide();
  }

  handleDeleteTemplateHandler() {
    this.showCloneTemplate = false;
    this.editTemplate = false;
    this.showAddNewTemplate = false;
    this.showDeleteTemplate = true;
    this.previewModal = false;
    this.showTemplate = false;
    this.template.querySelector('c-modal').show();
  }

  handleRefreshTemplateHandler(event) {
    setTimeout(() => {
      eval("$A.get('e.force:refreshView').fire();");
    }, 100);
  }

  selectItemEventHandler(event) {
    this.previewRecordId = event.detail.selectedRecord.recordId;
    this.templateId = this.doctemplatedetails.Id;
    this.templatename = this.doctemplatedetails.Name;
  }

  updateItemEventHandler(event) {
    this.previewRecordId = undefined;
  }

  handleEditSuccess(event) {
    const toastEvt = new ShowToastEvent({
      title: 'Success',
      message: 'Template "' + event.detail.fields.Name.value + '"' + this.popUpMessage.TEMPLATE_DESIGN_UPDATED,//'Edited Successfully',
      variant: 'Success',
    });
    this.dispatchEvent(toastEvt);
    let createdDocumentTemplateId = event.detail.id;
    let name = event.detail.fields.Name.value;
    let versionno = event.detail.fields.Dx_Temp__Version_Number__c.value;
    const newDocTempEvt = new CustomEvent('docedited', {
      detail: { id: createdDocumentTemplateId, name: name, version: versionno }, bubbles: true
    });
    this.dispatchEvent(newDocTempEvt);
    this.template.querySelector('c-modal').hide();
  }

/*
  handleSuccess(event) {
    let createdDocumentTemplateId = event.detail.id;
    let name = event.detail.fields.Name.value;
    let tempObj = {};
    tempObj.Id = createdDocumentTemplateId;
    tempObj.Name = event.detail.fields.Name.value;
    tempObj.Dx_Temp__Related_To_Type__c = event.detail.fields.Dx_Temp__Related_To_Type__c.value;
    this.relatedtoTypeObjName = event.detail.fields.Dx_Temp__Related_To_Type__c.value;
    this.relatedtoTypeObjChild = this.relatedtoTypeObjName;
    tempObj.Dx_Temp__IsActive__c = event.detail.fields.Dx_Temp__IsActive__c.value;
    tempObj.Dx_Temp__Version_Number__c = event.detail.fields.Dx_Temp__Version_Number__c.value
    const newDocTempEvt = new CustomEvent('doccreated', {
      detail: { id: createdDocumentTemplateId, name: name, templateObj: tempObj, templateObjName: this.relatedtoTypeObjChild }, bubbles: true
    });
    this.dispatchEvent(newDocTempEvt);
    const toastEvt = new ShowToastEvent({
      title: 'Success!',
      message: name + ' was Created',
      variant: 'Success',
    });
    this.dispatchEvent(toastEvt);
    this.template.querySelector('c-modal').hide();
  }
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

  cancelDeleteHandler() {
    this.template.querySelector('c-modal').hide();
  }

  permanantDeleteHandler() {
    deleteTemplate({ templateId: this.documenttemplaterecordid }).then(result => {
      console.log('successful');
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

  handleSubmit() {
    var allRecords = [];
    let data = this.sections;
    this.sections.forEach(function (val) {
      var Recorddetails = { Name: '', Dx_Temp__Sequence__c: 0, Dx_Temp__Type__c: '', Id: '' };
      Recorddetails.Id = val.Id;
      Recorddetails.Name = val.sectionNameEntered;
      Recorddetails.Dx_Temp__Sequence__c = val.index;
      Recorddetails.Dx_Temp__Type__c = val.Name;
      allRecords.push(Recorddetails);
    });
    this.isLoaded = true;
    saveDocumentTemplateSectionSequences({ allSectionRecords: allRecords })
      .then(result => {
        if (result != null) { this.isLoaded = false; }
      })
      .catch(error => { this.isLoaded = false; })
  }

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

  onDragOver(evt) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
  }

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
        this.dragMap.forEach((value, key, map) => {
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
}