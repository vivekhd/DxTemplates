import { LightningElement, track, api, wire } from 'lwc';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import ClauseBody from '@salesforce/apex/SaveDocumentTemplatesection.ClauseBody';
import deletetemplate from '@salesforce/apex/SaveDocumentTemplatesection.deletetemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import createUpdateMethod from '@salesforce/apex/LanguageTranslatorClass.createUpdateMethod';
import deleteMethod from '@salesforce/apex/LanguageTranslatorClass.deleteMethod';
import selectedLangMethod from '@salesforce/apex/LanguageTranslatorClass.selectedLangMethod';
import getAllUserLanguages from '@salesforce/apex/LanguageTranslatorClass.getAllUserLanguages';
import currectUserLang from '@salesforce/apex/LanguageTranslatorClass.currectUserLang';
import createLog from '@salesforce/apex/LogHandler.createLog';
import getSObjectListFiltering from '@salesforce/apex/RelatedObjectsClass.getSObjectListFiltering';
import createRuleCondition from '@salesforce/apex/RelatedObjectsClass.createRuleCondition';
import getConditions from '@salesforce/apex/RelatedObjectsClass.getExistingConditions';
import { createRuleConditionHierarcy } from 'c/conditionUtil';
import resetRulesForTemplate from '@salesforce/apex/RelatedObjectsClass.handleTemplateRuleResetCondition';
export default class TemplateContentDetails extends NavigationMixin(LightningElement) {
  isLoaded = false;
  showMergeFields = false;
  newpage = false;
  @api pdfLinks;
  @api documenttemplaterecord;
  @api selectedObjectName;
  @track relatedtoTypeObjChild;
  @api showdetails = false;
  @api recordidtoedit = '';
  @api showclausescreen = false;
  @api disableButton = false;
  @api disabledeleteButton = false;
  @api sectiontype = '';
  @api rowcount;
  @api recordidvalueprop;
  @api sectionrecordid;
  @track showBool = false;
  @track clauseId = '';
  @track richtextVal = 'Hello';
  @track value = [];
  @track mergefieldname;
  @track savedRecordID;
  isDisabled = false;
  selectedClauseId;
  @track ruleCondition = false;
  @track globalItems;
  @track selectedMergefields = [];
  @api whereCondition ="";
  whereClause = " IsActive__c = true";
  @track isTranslateModalOpen = false;
  @track translatedRecords=[{
        'Name': '',
        'DxCPQ__FieldValue__c': '',
        'DxCPQ__Translated_Value__c': '',
        'Id': ''
    }]; 
  @track languages = [];
  @track selectedLanguage; 
  uniqueIdentifierVal = 0;
  get uniqueIdentifier() {
        this.uniqueIdentifierVal = this.uniqueIdentifierVal + 1;
        return this.uniqueIdentifierVal;
  }
  @track dataArray = [{
              'Name': '',
              'DxCPQ__FieldValue__c': '',
              'DxCPQ__Translated_Value__c': '',
              'Id': this.uniqueIdentifier
          }]; 
  @track extractedWords = [];
  transRecordNameArray = [];
  translateEnabled = true;
  @api isSaved;
  @track Recorddetailsnew = {
    Name: '',
    DxCPQ__Section_Content__c: '',
    DxCPQ__DisplaySectionName__c: false,
    DxCPQ__New_Page__c: false,
    DxCPQ__Document_Template__c: '',
    DxCPQ__Sequence__c: 0,
    DxCPQ__Type__c: '',
    Id: '',
    DxCPQ__RuleId__c: '',
    DxCPQ__Document_Clause__c: '',
    DxCPQ__Section_Visibility_Rule__c:''
  };
    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'table',
        'header',
        'color',
        'code-block',
        'script', 'direction'
    ];
 //filter
  @track ruleCondition;
  @track listOfExistingConditions = [];
  @track fieldWrapper;
  ruleExpression;
  ruleConditions = [];
  ruleExists = false;
  allConditions=[];
  conditionExists=false;
  conditionsArr = [];
  mapOfRC = new Map();

  renderedCallback() {
    if (this.documenttemplaterecord && this.documenttemplaterecord.DxCPQ__Previously_Active__c == true) {
      this.handleActivateTemplate(true, this.selectedObjectName);
    }
  }

  handlename(event) {
    this.Recorddetailsnew.Name = event.detail.value;
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  selectItemEventHandler(event) {
    this.clauseId = event.detail.selectedRecord.recordId;
    this.selectedClauseId = event.detail.selectedRecord.recordId;
    this.richtextVal = event.detail.selectedRecord.recordObject.DxCPQ__Body__c;
    this.Recorddetailsnew.Name = event.detail.selectedRecord.recordName;
  }
  /*filter*/

  connectedCallback() {
    this.handleRuleWrapperMaking();
   // this.whereCondition = `DxCPQ__Document_Template__r.DxCPQ__Related_To_Type__c = '${this.selectedObjectName}' AND DxCPQ__Type__c = 'Context'`;
    this.whereClause = this.whereCondition;
    console.log('sectionrecordid',this.sectionrecordid);
    getAllUserLanguages()
      .then(result =>{
        this.languages = result.map(option => {
        return { label: option.label, value: option.value };
        });
      }).catch(error=>{
        let errorMessage = error.message || 'Unknown error message';
        let tempError = error.toString();
        createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
      });
      console.log('Languages----',this.languages);
  }
   handleFiltering() {
      this.ruleCondition = true;
      this.template.querySelector('[data-id="filter"]').show();
  }
   closePreviewModal() {
      this.ruleCondition = false;
      this.template.querySelector('[data-id="filter"]').hide();
  }
  handleRuleWrapperMaking() {
    if (this.selectedObjectName !== undefined) {
      getSObjectListFiltering({
        selectedChildObjectLabel: this.selectedObjectName
        })
      .then((result) => {
          this.fieldWrapper = result;
      })
      .catch((error) => {
          console.log('error while Filtering the Object -> handleRuleWrapperMaking', error);
      });
    }
  }
     handleCreateRules(event) {
      const conditionChild = this.template.querySelector('c-conditioncmp').getConditionDetails();
      this.ruleExpression = conditionChild.expression;
      this.createRuleConditionObjects(conditionChild.listOfConditions);
      let listOfConditions = JSON.stringify(this.ruleConditions);
      let deleteIds = null;
      let ruleExp = JSON.stringify(this.ruleExpression);
      createRuleCondition({
              ruleConditions: listOfConditions,
              ruleExpression: ruleExp,
              deleteIds: deleteIds,
              sectionrecordid: this.sectionrecordid
          })
          .then(result => {
              this.ruleIdCreated = result;
              this.ruleExists = true;
              let event = new Object();
              this.getExistingConditions(event);
          })
          .catch(error => {
              console.log('Error -> createRuleCondition' + JSON.stringify(error));
          });
      this.template.querySelector('[data-id="filter"]').hide();
  }
   createRuleConditionObjects(arrayList) {
      this.hasSpecialCharacter = false;
      let regExpr = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
      arrayList.forEach(condition => {
          let tempObj = {};
          tempObj.Id = condition.Id;
          tempObj.conditionName = condition.conditionName;
          tempObj.dataType = condition.dataType;
          if (condition.operator == '==') {
              tempObj.operator = '==';
          } else {
              tempObj.operator = condition.operator;
          }
          tempObj.selectedObject = condition.selectedObject;
          tempObj.selectedField = condition.selectedField;
          tempObj.value = condition.value;
          if (regExpr.test(tempObj.value)) {
              this.hasSpecialCharacter = true;
          }
          tempObj.conditionIndex = condition._index;
          this.ruleConditions.push(tempObj);
          if (condition.children && condition.children.length > 0) {
              condition.children.forEach(child => {
                  if (child.group && child.group.length > 0) {
                      this.createRuleConditionObjects(child.group);
                  }
              })
          }
      })
  }
   handleRuleUpdates(event) {
      this.ruleConditions = [];
      const conditionChild = this.template.querySelector('c-conditioncmp').getConditionDetails();
      this.createRuleConditionObjects(conditionChild.listOfConditions);
      let listOfConditions = JSON.stringify(this.ruleConditions);
      let expression = JSON.stringify(conditionChild.expression);
      let deleteIds = this.removeDeletedConditions(this.ruleConditions, this.conditionsArr);
      if (!this.hasSpecialCharacter) {
          createRuleCondition({
                  ruleConditions: listOfConditions,
                  ruleExpression: expression,
                  deleteIds: deleteIds,
                  sectionrecordid: this.sectionrecordid
              })
              .then(result => {
                  this.ruleExists = true;
                  this.ruleExpression = expression;

                  let event = new Object();
                  this.getExistingConditions(event);
              })
              .catch(error => {
                  console.log('createRuleCondition error occurred' + JSON.stringify(error));
              });
      }
      this.template.querySelector('[data-id="filter"]').hide();
  }
   getExistingConditions(event) {
      this.mapOfRC = new Map();
      this.conditionsArr = [];
      this.conditionExists = false;
      this.allConditions = [];
      this.listOfExistingConditions = [];
      getConditions({ ruleName: this.ruleIdCreated })
        .then(result => {
            if (result.length > 0) {
                this.conditionsArr = JSON.parse(JSON.stringify(result));
                this.lstofactualConditions = this.conditionsArr;
                this.conditionsArr.forEach(con => {
                    this.mapOfRC.set(con.Name, con);
                });
                if (this.fieldWrapper !== undefined) {
                    let conditionResult = createRuleConditionHierarcy(this.ruleExpression, this.mapOfRC, this.fieldWrapper);
                    this.listOfExistingConditions = conditionResult.listOfConditions;
                    this.selectedGlobalValue = conditionResult.selectedGlobalValue;
                    this.conditionExists = true;
                }
            }
        })
        .catch(error => {
            console.log('Apex Call getExistingConditions Erroneous');
            console.log(error);
        })
  }
  removeDeletedConditions(listOfConditions, receivedConditions) {
      let existingIds = [];
      let receivedIds = [];
      listOfConditions.forEach(con => {
          if (con.Id) {
              existingIds.push(con.Id);
          }
      })
      receivedConditions.forEach(con => {
          receivedIds.push(con.Id);
      })
      receivedIds = receivedIds.filter(el => {
          return !existingIds.includes(el);
      });
      return receivedIds;
  }
    handleFilterRuleReset() {

      resetRulesForTemplate({
              templateRuleId: this.ruleIdCreated
          })
          .then(result => {
              if (result == 'Success') {

                  this.ruleIdCreated = null;

                  this.listOfExistingConditions = [];
                  this.conditionsArr = [];
                  this.ruleExists = false;
                  this.filteringCondition = '';
                  this.ruleConditions = [];
                  this.ruleCondition = false;

                  this.handlesectionsave(null);
              } else {
                  const Errormsg = new ShowToastEvent({
                      title: 'Error',
                      message: 'Reset didn\'t work',
                      variant: 'Error'
                  });
                  this.dispatchEvent(Errormsg);
              }
          })
          .catch(error => {
              console.log('reset Rules error occurred' + JSON.stringify(error));
          });
      this.ruleCondition = false;
      this.template.querySelector('c-modal').hide();
  }

  /*filter*/
  updateItemEventHandler(event) {
    this.selectedClauseId = undefined;
    this.richtextVal = '';
    this.Recorddetailsnew.Name = '';
  }

  handleClauseSelection(event) {
    this.clauseId = event.detail.value;
    const clauseIdstring = JSON.stringify(this.clauseId)
    ClauseBody({ inputparam: clauseIdstring })
      .then(result => {
        if (result != null) {
          this.richtextVal = result.DxCPQ__Body__c;
          this.Recorddetailsnew.Name = result.Name;
        }
      })
      .catch(error => {
        let errorMessage = error.message || 'Unknown error message';
          let tempError = error.toString();
          createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
        });
  }

  @api handleObjectNameSelection(objName) {
    this.selectedObjectName = objName;
  }

  @api handleActivateTemplate(isActive, objName) {
    this.selectedObjectName = objName;
    this.isDisabled = isActive;
    this.disableButton = isActive;
    this.disabledeleteButton = isActive;
  }

  handlechange(event) {
    this.newpage = event.detail.checked;
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  handleclauseremoval() {
    this.richtextVal = '';
    this.Recorddetailsnew.Name = '';
  }

  handlesectionsave(event) {
    var richtextvalvar = this.richtextVal;
    var mergefieldsfinalList = [];

    this.selectedMergefields.forEach(val => {
      if (richtextvalvar.localeCompare(val) == 0) {
        mergefieldsfinalList.push(val);
      }
    });

    var currecid = this.sectionrecordid;
    if (this.richtextVal != '' && this.richtextVal != null) {
      if (this.newpage) {
        this.Recorddetailsnew.DxCPQ__Section_Content__c = "<div style=\"page-break-before : always;\">" + this.richtextVal + "</div>";
      } else {
        this.Recorddetailsnew.DxCPQ__Section_Content__c = this.richtextVal;
      }
      this.Recorddetailsnew.DxCPQ__New_Page__c = this.newpage;
    }

    if (currecid != '' && this.sectionrecordid.indexOf('NotSaved') == -1) {
      this.Recorddetailsnew.Id = this.sectionrecordid;
    }
    this.Recorddetailsnew.DxCPQ__Sequence__c = this.rowcount;
    this.Recorddetailsnew.DxCPQ__Type__c = this.sectiontype;
    this.Recorddetailsnew.DxCPQ__RuleId__c = '';
    this.Recorddetailsnew.DxCPQ__Section_Visibility_Rule__c = this.ruleIdCreated;

    let clauseCheck = true;
    if (this.Recorddetailsnew.DxCPQ__Type__c == 'Clause') {
      if (this.clauseId != '' && this.clauseId != null) {
        this.Recorddetailsnew.DxCPQ__Document_Clause__c = JSON.stringify(this.clauseId);
      }
      else {
        clauseCheck = false;
      }
    }

    this.Recorddetailsnew.DxCPQ__Document_Template__c = this.documenttemplaterecord.Id;
    if (this.Recorddetailsnew.Name != '' && this.Recorddetailsnew.Name != null && clauseCheck) {
      saveDocumentTemplateSectionDetails({ Recorddetails: this.Recorddetailsnew })
        .then(result => {
          if (result != null) {
            this.savedRecordID = result;
            const event4 = new ShowToastEvent({
              title: 'Success',
              message: 'Section "' + this.Recorddetailsnew.Name + '"' + ' was Saved',
              variant: 'success',
            });
            this.dispatchEvent(event4);
            var firecustomevent = new CustomEvent('savesectiondata', { detail: this.savedRecordID });
            this.dispatchEvent(firecustomevent);
            const saveEvent = new CustomEvent('datasaved', {detail: true });
            this.dispatchEvent(saveEvent);
            this.translateEnabled = false;
          }
        })
        .catch(error => {
          let errorMessage = error.message || 'Unknown error message';
          let tempError = error.toString();
          createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
        });
      this.clickedfirsttime = true;
    }
    else {
      var error = 'Please enter the required details to save this section.';
      if(!clauseCheck){ error = 'Please select a pre-defined Clause to save this section.'}
      const Errormsg = new ShowToastEvent({
        title: 'Error',
        message: error,
        variant: 'Error',
      });
      this.dispatchEvent(Errormsg);
    }
    this.newpage = false;
  }

  handlecheckboxChange(event) {
    const mystring = JSON.stringify(event.detail.value);

    if (mystring.includes('New Page')) {
      this.Recorddetailsnew.DxCPQ__New_Page__c = true;
    } else {
      this.Recorddetailsnew.DxCPQ__New_Page__c = false;
    }

    if (mystring.includes('Display Section Name')) {
      this.Recorddetailsnew.DxCPQ__DisplaySectionName__c = true;
    } else {
      this.Recorddetailsnew.DxCPQ__DisplaySectionName__c = false;
    }
  }


  handlemergefieldselection(event) {
    this.mergefieldname = '{!' + this.documenttemplaterecord.DxCPQ__Related_To_Type__c + '.' + event.detail.value + '}';
  }

  handlemergefieldadd() {
    this.isTranslateModalOpen = false;
    this.template.querySelector('c-modal').show();
  }

  handlerowlevelmerge(event) {
    this.selectedRowIndex = event.currentTarget.dataset.index;
    this.isTranslateModalOpen = false;
    this.rowlevelmerge = true;
    this.template.querySelector('c-modal').show();
  }

  getMergeFieldCopy() {
    const mergeField = this.template.querySelector('c-dx-lookup-fields-displaycmp').getMergeField();
    if (mergeField != undefined) {
      this.mergefieldname = '{!' + this.selectedObjectName + '.' + mergeField + '}';
      let tag = document.createElement('textarea');
      tag.setAttribute('id', 'input_test_id');
      tag.value = this.mergefieldname;
      document.getElementsByTagName('body')[0].appendChild(tag);
      document.getElementById('input_test_id').select();
      document.execCommand('copy');
      document.getElementById('input_test_id').remove();
      this.selectedMergefields.push(this.mergefieldname);
    }
    this.template.querySelector('c-modal').hide();
  }

  getMergeField() {
    const mergeField = this.template.querySelector('c-dx-lookup-fields-displaycmp').getMergeField();
    if (mergeField != undefined) {
      this.mergefieldname = '{!' + this.selectedObjectName + '.' + mergeField + '}';
      if(this.rowlevelmerge){
        //let rowIndex = this.selectedRowIndex;
            this.isTranslateModalOpen = true;
            let updatedRecords = [...this.translatedRecords];
                updatedRecords[this.selectedRowIndex] = {
                    ...updatedRecords[this.selectedRowIndex],
                    Name: this.mergefieldname
                };
                this.translatedRecords = updatedRecords;
            //this.translatedRecords[this.selectedRowIndex].Name = this.mergefieldname; // Update the "Field Label" column
            this.rowlevelmerge = false;
      }
      else{
        this.richtextVal += this.mergefieldname;
        this.template.querySelector('c-modal').hide();
      }
      this.selectedMergefields.push(this.mergefieldname);
    }
  }

  handleRichTextArea(event) {
    this.Recorddetailsnew.DxCPQ__Section_Content__c = event.detail.value;
    if(this.richtextVal != event.detail.value){
    this.richtextVal = event.detail.value;
    this.translateEnabled = this.richtextVal != null || this.richtextVal != ''? false: true;
      const saveEvent = new CustomEvent('datasaved', {detail: false });
      this.dispatchEvent(saveEvent);
    }
  }

  handlesectionDelete(event) {
    if (this.sectionrecordid.indexOf('NotSaved') !== -1) {
      var firecustomevent = new CustomEvent('deletesectiondata', { detail: this.sectionrecordid });
      this.dispatchEvent(firecustomevent);
    }
    else {
      deletetemplate({ secidtobedeleted: this.sectionrecordid, doctemplateid: this.documenttemplaterecord.Id })
        .then(result => {
          if (result != null) {
            var firecustomevent = new CustomEvent('deletesectiondata', { detail: this.sectionrecordid });
            this.dispatchEvent(firecustomevent);
          }
        })
        .catch(error => {
          let errorMessage = error.message || 'Unknown error message';
          let tempError = error.toString();
          createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
        });
    }
  }

  @api resetvaluesonchildcmp() {
    this.dispatchEvent(new CustomEvent('datasaved', {detail: true }));
    this.showclause = false;
    this.ukey = (new Date()).getTime();
    this.Recorddetailsnew.Id = '';
    this.Recorddetailsnew.Name = '';
    this.Recorddetailsnew.DxCPQ__DisplaySectionName__c = '';
    this.richtextVal = '';
    this.clauseId = '';
    this.Recorddetailsnew.DxCPQ__New_Page__c = false;
    this.Recorddetailsnew.DxCPQ__Section_Visibility_Rule__c = '';
    this.newpage = false;
    this.isTranslateModalOpen = false;
    this.rowlevelmerge = false;
    this.selectedRowIndex;
    this.Recorddetailsnew = {
    Name: '',
    DxCPQ__Section_Content__c: '',
    DxCPQ__DisplaySectionName__c: false,
    DxCPQ__New_Page__c: false,
    DxCPQ__Document_Template__c: '',
    DxCPQ__Sequence__c: 0,
    DxCPQ__Type__c: '',
    Id: '',
    DxCPQ__RuleId__c: '',
    DxCPQ__Document_Clause__c: '',
    DxCPQ__Section_Visibility_Rule__c:''
  };
  this.handleRuleWrapperMaking();
  this.ruleCondition = false;
  this.listOfExistingConditions = [];
  this.fieldWrapper=[];
  this.ruleIdCreated='';
  this.ruleExpression = '';
  this.ruleConditions = [];
  this.ruleExists = false;
  this.allConditions=[];
  this.conditionExists=false;
  this.conditionsArr = [];
  this.mapOfRC = new Map();
    this.template.querySelectorAll('lightning-input-rich-text').forEach(element => {
      if (element.value != null) {
        element.value = '';
      }
    });

    this.template.querySelectorAll('lightning-checkbox-group ').forEach(element => {
      if (element.value != null) {
        element.value = '';
      }
    });
    setTimeout(() => { 
      try{
        this.template.querySelector('[data-id="newpage"]').checked = this.newpage; 
      }
      catch(error){
        console.log('error in setTimeout for checked error >> ', error.message);
      }
      });
  }

  @api loadsectionsectionvaluesforedit(recordID) {
    this.isLoaded = true;
    this.value = [];
    this.ruleExists = false;
    this.sectionrecordid = recordID;
    this.Recorddetailsnew.Id = recordID;
    gettemplatesectiondata({ editrecordid: recordID })
      .then(result => {
        this.isLoaded = false;
        if (result != null) {
          this.Recorddetailsnew.Name = result.Name;
          this.Recorddetailsnew.DxCPQ__Document_Template__c = result.DxCPQ__Document_Template__c;
          this.Recorddetailsnew.DxCPQ__Sequence__c = result.DxCPQ__Sequence__c;
          this.Recorddetailsnew.DxCPQ__Type__c = result.DxCPQ__Type__c;
          this.Recorddetailsnew.DxCPQ__New_Page__c = result.DxCPQ__New_Page__c;
          this.Recorddetailsnew.DxCPQ__DisplaySectionName__c = result.DxCPQ__DisplaySectionName__c;
          this.Recorddetailsnew.DxCPQ__Section_Content__c = result.DxCPQ__Section_Content__c;
          this.Recorddetailsnew.DxCPQ__Section_Visibility_Rule__c = result.DxCPQ__Section_Visibility_Rule__c;
          this.sectiontype = result.DxCPQ__Type__c;
          if (this.Recorddetailsnew.DxCPQ__Type__c == 'Clause' && result.DxCPQ__Document_Clause__c != null) {
            this.clauseId = result.DxCPQ__Document_Clause__c;
            let tempObj = { recordId: result.DxCPQ__Document_Clause__c, recordName: result.DxCPQ__Document_Clause__r.Name }
            this.template.querySelector('c-multi-lookup-component').selectedRecordHandler(tempObj);
            this.ukey = (new Date()).getTime();
          }
          this.newpage = result.DxCPQ__New_Page__c;
          setTimeout(() => { 
            try{
              this.template.querySelector('[data-id="newpage"]').checked = this.newpage; 
            }
            catch(error){
              console.log('error in setTimeout for checked error >> ', error.message);
            }
              
            });

          if (result.DxCPQ__Section_Content__c != null) {
            this.richtextVal = result.DxCPQ__Section_Content__c;
            this.translateEnabled = false;
          } else if (result.DxCPQ__Section_Content__c == undefined) {
            this.richtextVal = '';
          }
          if (result.DxCPQ__Section_Visibility_Rule__c != null && result.DxCPQ__Section_Visibility_Rule__c != '') {
                      this.Recorddetailsnew.DxCPQ__Section_Visibility_Rule__c = result.DxCPQ__Section_Visibility_Rule__c;
                      this.ruleExpression = result.DxCPQ__Section_Visibility_Rule__r.DxCPQ__Rule_Expression__c;
                  } else {
                      this.Recorddetailsnew.DxCPQ__Section_Visibility_Rule__c = '';
                  }
          if (result.DxCPQ__Section_Visibility_Rule__c != null) {
                      this.ruleIdCreated = result.DxCPQ__Section_Visibility_Rule__c;
                      this.ruleExists = true;
                  } else {
                      this.ruleIdCreated = null;
                      this.listOfExistingConditions = [];
                      this.conditionsArr = [];
                      this.ruleExists = false;
                      this.filteringCondition = '';
                  }

                  if (this.ruleIdCreated != null && this.ruleIdCreated != '') {
                      this.handleRuleWrapperMaking();
                      let event = new Object();
                      this.getExistingConditions(event);
                      this.ruleExists = true;
          }
          this.template.querySelectorAll('lightning-checkbox-group ').forEach(element => {
            if (result.DxCPQ__New_Page__c == true) {
              this.value.push('New Page');
            }
            if (result.DxCPQ__DisplaySectionName__c == true) {
              this.value.push('Display Section Name');
            }
          });
        }
      })
      .catch(error => {
        this.isLoaded = false;
        let errorMessage = error.message || 'Unknown error message';
        let tempError = error.toString();
        createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
      });
  }


  handlehelp(){
    let urlLink;
        if(this.showclausescreen){ //for clause screen
      let relatedObjectsMap = this.pdfLinks.find(item => item.MasterLabel === 'Clause');
      urlLink = relatedObjectsMap ? relatedObjectsMap.DxCPQ__Section_PDF_URL__c : null;
          }
    else{//for context screen
      let relatedObjectsMap = this.pdfLinks.find(item => item.MasterLabel === 'Context');
      urlLink = relatedObjectsMap ? relatedObjectsMap.DxCPQ__Section_PDF_URL__c : null;
          }
    const config = {
        type: 'standard__webPage',
        attributes: {
            url: urlLink
          }
    };
    this[NavigationMixin.Navigate](config);
  }

  handleTranslate(event) {
      this.extractedWords = [];
      this.extractWords();
      this.isTranslateModalOpen = true;
      this.template.querySelector('c-modal').show();

      /* getAllUserLanguages()
      .then(result =>{
        this.languages = result.map(option => {
        return { label: option.label, value: option.value };
        });
      }).catch(error=>{
        let errorMessage = error.message || 'Unknown error message';
        let tempError = error.toString();
        createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
      }); */

      currectUserLang()
      .then(result => {
        this.selectedLanguage = this.getLanguageValueByLabel(result); // Set the default value to English
        this.transRecordsRetrive();
      })
      .catch(error => {
        console.log('Error--',error.message);
        let errorMessage = error.message || 'Unknown error message';
        let tempError = error.toString();
        createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
      });
  }

  getLanguageValueByLabel(label) {
    const language = this.languages.find(lang => lang.label === label);
    return language ? language.value : null;
  }

//   extractWords() {
//       const regex = /&lt;&lt;([^>]+?)&gt;&gt;/g;
//       let m;
//       while ((m = regex.exec(this.richtextVal)) !== null) {
//         // This is necessary to avoid infinite loops with zero-width matches
//         if (m.index === regex.lastIndex) {
//           regex.lastIndex++;
//         }
        
//         // The result can be accessed through the `m`-variable.
//         m.forEach((match, groupIndex) => {
//           if(groupIndex%2!=0) this.extractedWords.push(match);
//         });
//       }
//   }


  //code added by Bhavya for extracting the merge fields along with the tokens
  extractWords(){
    let decodedRichtextVal = this.richtextVal.replace(/&lt;/g, '<').replace(/&gt;/g, '>');
    let regex = /<<([^>]+?)>>|({![^}]+?})/g;
    let m;
    while ((m = regex.exec(decodedRichtextVal)) !== null) {
      if (m.index === regex.lastIndex) {
        regex.lastIndex++;
      }
      if (m[1]) {
        this.extractedWords.push(m[1]);
      } else if (m[2]) {
        this.extractedWords.push(m[2]);
      }
    }
    console.log('this.extractedWords after extractwords ----> ', this.extractedWords);
  }

  transRecordsRetrive(){
    selectedLangMethod({language : this.selectedLanguage, extractedWords : JSON.stringify(this.extractedWords), docTempId : this.documenttemplaterecord.Id })
          .then(result => {
          if (result && result.length > 0) {
            this.translatedRecords = [];
            this.transRecordNameArray = [];
              result.forEach(record => {
                  // Iterate over each record and push it into translatedRecords array
                  this.transRecordNameArray.push(record.Name);
                  this.translatedRecords.push({
                      'Name': record.Name,
                      'DxCPQ__FieldValue__c': record.DxCPQ__FieldValue__c,
                      'DxCPQ__Translated_Value__c': record.DxCPQ__Translated_Value__c,
                      'Id': record.Id
                  });
              });
              if(this.transRecordNameArray.length != this.extractedWords.length){
                this.extractedWords.forEach((extraxtElem) => {
                if(!this.transRecordNameArray.includes(extraxtElem)){
                  this.translatedRecords.push({
                    'Name': extraxtElem,
                    'DxCPQ__FieldValue__c': '',
                    'DxCPQ__Translated_Value__c': '',
                    'Id':''
                  });
                }})
              }
              else{
                //code for when this.transRecordNameArray & this.extractedwords are of same length
                this.extractedWords.forEach(word => {
                  if (!this.transRecordNameArray.includes(word)) 
                  {
                    this.transRecordNameArray.push(word);
                    this.translatedRecords.push({
                      'Name': word,
                      'DxCPQ__FieldValue__c': '',
                      'DxCPQ__Translated_Value__c': '',
                      'Id':''
                    });
                  }
                  });
                }
              //this.selectedLanguage = this.translatedRecords[0].DxCPQ__Language__c;
          } else {
            this.translatedRecords = [];
            if(this.extractedWords.length>0){
              this.extractedWords.forEach((extraxtElem) => {
              this.translatedRecords.push({
                'Name': extraxtElem,
                'DxCPQ__FieldValue__c': '',
                'DxCPQ__Translated_Value__c': '',
                'Id': ''
                });
              })
            } else {
              this.translatedRecords = this.dataArray;
            }
          }})
          .catch(error => {
            let errorMessage = error.message || 'Unknown error message';
            let tempError = error.toString();
            createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
          });
  }

  handleClick() {
  const newDataArray = {
          'Name': '',
          'DxCPQ__FieldValue__c': '',
          'DxCPQ__Translated_Value__c': '',
          'Id' : this.uniqueIdentifier
      };
      this.translatedRecords.push(newDataArray);
  }

  handleRemoveRow(event) {
      event.preventDefault();
      const indexVal = event.target.dataset.index;
      //let rowDelete= false;
      /* const deleteData = [{
          'FieldName': this.translatedRecords[indexVal].Name,
          'FieldValue': this.translatedRecords[indexVal].DxCPQ__FieldValue__c,
          'TranslatedValue': this.translatedRecords[indexVal].DxCPQ__Translated_Value__c,
          'Id': this.translatedRecords[indexVal].Id
      }]; */

      var id = this.translatedRecords[indexVal].Id;
      var regex = /^([a-zA-Z0-9_-]){18}$/;

      if(regex.test(id)){
          deleteMethod({deleteRecordId : id })
          .then(result => {
            if(result){
              this.translatedRecords.splice(indexVal, 1);
              this.translatedRecords = [...this.translatedRecords];
              this.showToast('Success', 'Record deleted successfully', 'success'); 
            }else{
              this.showToast('Error', 'Error in deleting records, please check the logs', 'error');
            }    
          }).catch(error => {
            this.showToast('Error', 'An error occurred while deliting the record', 'error');   
            let errorMessage = error.message || 'Unknown error message';
            let tempError = error.toString();
            createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
          });
      }else{
          this.translatedRecords.splice(indexVal, 1);
          this.translatedRecords = [...this.translatedRecords];
      }
  }

  handleLanguageChange(event) {
    this.selectedLanguage = event.detail.value;
    this.transRecordsRetrive();
  }

  handleCellOneInputChange(event) {
    const indexVal = parseInt(event.target.dataset.index);
    // Check if indexVal is valid
    if (isNaN(indexVal) || indexVal < 0 || indexVal >= this.translatedRecords.length) {
      console.error('Invalid index:', indexVal);
      return;
    } 
    this.translatedRecords[indexVal].Name = event.target.value; 
  }

  handleCellTwoInputChange(event) {
    const indexVal = parseInt(event.target.dataset.index);
    if(isNaN(indexVal) || indexVal<0 || indexVal >= this.translatedRecords.length){
      console.error('Invalid index:', indexVal);
      return;
    }
    this.translatedRecords[indexVal].DxCPQ__FieldValue__c = event.target.value; 
  }

  handleCellThreeInputChange(event) {
    const indexVal = parseInt(event.target.dataset.index);
    if(isNaN(indexVal) || indexVal<0 || indexVal >= this.translatedRecords.length){
      console.error('Invalid index:', indexVal);
    }
    this.translatedRecords[indexVal].DxCPQ__Translated_Value__c = event.target.value; 
  }

  handleSave() {
    this.translatedRecords.forEach(record => {
      if (record.Name === null || record.Name === '') {
        this.showToast('Error','Some of the row(s) Name has no values','error');
      }
    });

    let fieldNameRequire = true;
    this.translatedRecords.forEach(record => {
      if (!record.Name) {
        fieldNameRequire = false;
      }
    });

    if(fieldNameRequire){
      this.translatedRecords.forEach(record => {
        // Rename DxCPQ__FieldValue__c to FieldValue
        if (record.hasOwnProperty('DxCPQ__FieldValue__c')) {
          record.FieldValue = record['DxCPQ__FieldValue__c'];
          delete record['DxCPQ__FieldValue__c'];
        }
        
        // Rename DxCPQ__Translated_Value__c to TranslatedValue
        if (record.hasOwnProperty('DxCPQ__Translated_Value__c')) {
          record.TranslatedValue = record['DxCPQ__Translated_Value__c'];
          delete record['DxCPQ__Translated_Value__c'];
        }
      });

      createUpdateMethod({ 
        jsonStringData: JSON.stringify(this.translatedRecords), 
        language: this.selectedLanguage,
        sectionId: this.sectionrecordid
      })
      .then(result => {
        this.showToast('Success', 'Record saved successfully', 'success'); 
        this.isTranslateModalOpen = false;
        this.translatedRecords = [];
      })
      .catch(error => {
        this.showToast('Error', 'An error occurred while saving the record', 'error');
        let errorMessage = error.message || 'Unknown error message';
        let tempError = error.toString();
        createLog({ recordId: '', className: 'TemplateContentDetails LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });});
      }

      /* else{
        this.showToast('Error', 'Please fill Field Names in all rows', 'error');
      } */
      this.template.querySelector('c-modal').hide();
    }
    
  
  showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  closeTranslateModal() {
      if(this.isTranslateModalOpen){
        this.translatedRecords = [];
        this.transRecordNameArray = [];
        this.extractedWords = [];
        this.isTranslateModalOpen = false;
      }
      this.template.querySelector('c-modal').hide();
  }

   //code added by Bhavya for adding Custom Font-family list - compatible with VF PDF generation
  get fontFamilies() {
    return [
        { label: 'Times New Roman', value: 'serif' },
        { label: 'Arial', value: 'sans-serif' },
        { label: 'serif', value: 'serif' },
        { label: 'Courier', value: 'courier' },
    ];
  }

  handleFontFamilySelection(event){
    let applySelectedFormats = {
        font: event.target.value,
    };
    let selection = window.getSelection().toString();
    let editor = this.template.querySelector('lightning-input-rich-text');
    editor.setFormat(applySelectedFormats);
  }
}