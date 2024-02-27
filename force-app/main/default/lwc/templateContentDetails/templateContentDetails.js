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
    DxCPQ__Section_Content__c: '',
    DxCPQ__DisplaySectionName__c: false,
    DxCPQ__New_Page__c: false,
    DxCPQ__Document_Template__c: '',
    DxCPQ__Sequence__c: 0,
    DxCPQ__Type__c: '',
    Id: '',
    DxCPQ__RuleId__c: '',
    DxCPQ__Document_Clause__c: ''
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
    if (this.documenttemplaterecord && this.documenttemplaterecord.DxCPQ__Previously_Active__c == true) {
      this.handleActivateTemplate(true, this.selectedObjectName);
    }
  }

  handlename(event) {
    this.Recorddetailsnew.Name = event.detail.value;
  }

  selectItemEventHandler(event) {
    this.clauseId = event.detail.selectedRecord.recordId;
    this.selectedClauseId = event.detail.selectedRecord.recordId;
    this.richtextVal = event.detail.selectedRecord.recordObject.DxCPQ__Body__c;
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
          this.richtextVal = result.DxCPQ__Body__c;
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
    this.mergefieldname = '{!' + this.documenttemplaterecord.DxCPQ__Related_To_Type__c + '.' + event.detail.value + '}';
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
    this.Recorddetailsnew.DxCPQ__Section_Content__c = event.detail.value;
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
    this.Recorddetailsnew.DxCPQ__DisplaySectionName__c = '';
    this.richtextVal = '';
    this.clauseId = '';
    this.Recorddetailsnew.DxCPQ__New_Page__c = false;
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
          } else if (result.DxCPQ__Section_Content__c == undefined) {
            this.richtextVal = '';
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
        console.log('Error while fetching data ' + JSON.stringify(error));
      })
  }
}