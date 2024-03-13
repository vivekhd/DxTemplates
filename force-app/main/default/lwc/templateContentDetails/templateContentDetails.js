import { LightningElement, track, api, wire } from 'lwc';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import ClauseBody from '@salesforce/apex/SaveDocumentTemplatesection.ClauseBody';
import deletetemplate from '@salesforce/apex/SaveDocumentTemplatesection.deletetemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';

export default class TemplateContentDetails extends LightningElement {
  isLoaded = false;
  showMergeFields = false;
  newpage = false;
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
  @track globalItems;
  @track selectedMergefields = [];
  whereClause = " IsActive__c = true";
  @track Recorddetailsnew = {
    Name: '',
    Dx_Temp__Section_Content__c: '',
    Dx_Temp__DisplaySectionName__c: false,
    Dx_Temp__New_Page__c: false,
    Dx_Temp__Document_Template__c: '',
    Dx_Temp__Sequence__c: 0,
    Dx_Temp__Type__c: '',
    Id: '',
    Dx_Temp__RuleId__c: '',
    Dx_Temp__Document_Clause__c: ''
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
  ];

  renderedCallback() {
    if (this.documenttemplaterecord && this.documenttemplaterecord.Dx_Temp__Previously_Active__c == true) {
      this.handleActivateTemplate(true, this.selectedObjectName);
    }
  }

  handlename(event) {
    this.Recorddetailsnew.Name = event.detail.value;
  }

  selectItemEventHandler(event) {
    this.clauseId = event.detail.selectedRecord.recordId;
    this.selectedClauseId = event.detail.selectedRecord.recordId;
    this.richtextVal = event.detail.selectedRecord.recordObject.Dx_Temp__Body__c;
    this.Recorddetailsnew.Name = event.detail.selectedRecord.recordName;
  }

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
          this.richtextVal = result.Dx_Temp__Body__c;
          this.Recorddetailsnew.Name = result.Name;
        }
      })
      .catch(error => {
        console.log('Content Section Error', error);
      })
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
        this.Recorddetailsnew.Dx_Temp__Section_Content__c = "<div style=\"page-break-before : always;\">" + this.richtextVal + "</div>";
      } else {
        this.Recorddetailsnew.Dx_Temp__Section_Content__c = this.richtextVal;
      }
      this.Recorddetailsnew.Dx_Temp__New_Page__c = this.newpage;
    }

    if (currecid != '' && this.sectionrecordid.indexOf('NotSaved') == -1) {
      this.Recorddetailsnew.Id = this.sectionrecordid;
    }
    this.Recorddetailsnew.Dx_Temp__Sequence__c = this.rowcount;
    this.Recorddetailsnew.Dx_Temp__Type__c = this.sectiontype;
    this.Recorddetailsnew.Dx_Temp__RuleId__c = '';

    let clauseCheck = true;
    if (this.Recorddetailsnew.Dx_Temp__Type__c == 'Clause') {
      if (this.clauseId != '' && this.clauseId != null) {
        this.Recorddetailsnew.Dx_Temp__Document_Clause__c = JSON.stringify(this.clauseId);
      }
      else {
        clauseCheck = false;
      }
    }

    this.Recorddetailsnew.Dx_Temp__Document_Template__c = this.documenttemplaterecord.Id;
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
          }
        })
        .catch(error => {
          console.log('Error in saving this section ' + JSON.stringify(error));
        })
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
      this.Recorddetailsnew.Dx_Temp__New_Page__c = true;
    } else {
      this.Recorddetailsnew.Dx_Temp__New_Page__c = false;
    }

    if (mystring.includes('Display Section Name')) {
      this.Recorddetailsnew.Dx_Temp__DisplaySectionName__c = true;
    } else {
      this.Recorddetailsnew.Dx_Temp__DisplaySectionName__c = false;
    }
  }


  /* @wire(getSobjectFields, {selectedObject: this.selectedObjectName}) 
 // @wire(getSobjectFields, {selectedObject: this.documenttemplaterecord.Related_To_Type__c}) 
    wiredSobjectfields({ error, data }) {
      if (data) {
          this.data = data;
          this.error = undefined;
      } else if (error) {
          this.error = error;
          console.log('occured error is '+ JSON.stringify(this.error));
      }
  }  */

  /*
  @wire(getSobjectFields, { selectedObject: '$selectedObjectName' })
  wiredSobjectfields({ error, data }) {
    if (data) {
      console.log('date ****' + data);
      this.data = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      console.log('occured error is ' + JSON.stringify(this.error));
    }
  }

  get selectedObject() {
    return this.selectedObjectName;
  }

  get fieldOptions() {
    var returnOptions = [];
    if (this.data) {
      this.data.forEach(ele => {
        returnOptions.push({ label: ele, value: ele });
      });
    }
    return returnOptions;
  }
  */

  handlemergefieldselection(event) {
    this.mergefieldname = '{!' + this.documenttemplaterecord.Dx_Temp__Related_To_Type__c + '.' + event.detail.value + '}';
  }

  handlemergefieldadd() {
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
      this.richtextVal += this.mergefieldname;
      this.selectedMergefields.push(this.mergefieldname);
    }
    this.template.querySelector('c-modal').hide();
  }

  handleRichTextArea(event) {
    this.Recorddetailsnew.Dx_Temp__Section_Content__c = event.detail.value;
    this.richtextVal = event.detail.value;
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
          console.log('section deletion failed' + JSON.stringify(error));
        })
    }
  }

  @api resetvaluesonchildcmp() {
    this.showclause = false;
    this.ukey = (new Date()).getTime();
    this.Recorddetailsnew.Id = '';
    this.Recorddetailsnew.Name = '';
    this.Recorddetailsnew.Dx_Temp__DisplaySectionName__c = '';
    this.richtextVal = '';
    this.clauseId = '';
    this.Recorddetailsnew.Dx_Temp__New_Page__c = false;
    this.newpage = false;

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
    setTimeout(() => { this.template.querySelector('[data-id="newpage"]').checked = this.newpage; });
  }

  @api loadsectionsectionvaluesforedit(recordID) {
    this.isLoaded = true;
    this.value = [];
    this.Recorddetailsnew.Id = recordID;
    gettemplatesectiondata({ editrecordid: recordID })
      .then(result => {
        this.isLoaded = false;
        if (result != null) {
          this.Recorddetailsnew.Name = result.Name;
          this.Recorddetailsnew.Dx_Temp__Document_Template__c = result.Dx_Temp__Document_Template__c;
          this.Recorddetailsnew.Dx_Temp__Sequence__c = result.Dx_Temp__Sequence__c;
          this.Recorddetailsnew.Dx_Temp__Type__c = result.Dx_Temp__Type__c;
          this.Recorddetailsnew.Dx_Temp__New_Page__c = result.Dx_Temp__New_Page__c;
          this.Recorddetailsnew.Dx_Temp__DisplaySectionName__c = result.Dx_Temp__DisplaySectionName__c;
          this.Recorddetailsnew.Dx_Temp__Section_Content__c = result.Dx_Temp__Section_Content__c;

          this.sectiontype = result.Dx_Temp__Type__c;
          if (this.Recorddetailsnew.Dx_Temp__Type__c == 'Clause' && result.Dx_Temp__Document_Clause__c != null) {
            this.clauseId = result.Dx_Temp__Document_Clause__c;
            let tempObj = { recordId: result.Dx_Temp__Document_Clause__c, recordName: result.Dx_Temp__Document_Clause__r.Name }
            this.template.querySelector('c-multi-lookup-component').selectedRecordHandler(tempObj);
            this.ukey = (new Date()).getTime();
          }
          this.newpage = result.Dx_Temp__New_Page__c;
          setTimeout(() => { this.template.querySelector('[data-id="newpage"]').checked = this.newpage; });

          if (result.Dx_Temp__Section_Content__c != null) {
            this.richtextVal = result.Dx_Temp__Section_Content__c;
          } else if (result.Dx_Temp__Section_Content__c == undefined) {
            this.richtextVal = '';
          }
          this.template.querySelectorAll('lightning-checkbox-group ').forEach(element => {
            if (result.Dx_Temp__New_Page__c == true) {
              this.value.push('New Page');
            }
            if (result.Dx_Temp__DisplaySectionName__c == true) {
              this.value.push('Display Section Name');
            }
          });
        }
      })
      .catch(error => {
        this.isLoaded = false;
        console.log('Error while fetching data ' + JSON.stringify(error));
      })
  }
}