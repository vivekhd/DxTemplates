import { LightningElement, wire, api, track } from 'lwc';
import getContentVersions from '@salesforce/apex/FooterClass.getContentVersions';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import createUpdateMethod from '@salesforce/apex/LanguageTranslatorClass.createUpdateMethod';
import deleteMethod from '@salesforce/apex/LanguageTranslatorClass.deleteMethod';
import selectedLangMethod from '@salesforce/apex/LanguageTranslatorClass.selectedLangMethod';
import getAllUserLanguages from '@salesforce/apex/LanguageTranslatorClass.getAllUserLanguages';
import createLog from '@salesforce/apex/LogHandler.createLog';
import currectUserLang from '@salesforce/apex/LanguageTranslatorClass.currectUserLang';
import { NavigationMixin } from 'lightning/navigation';

export default class TemplateFooter extends NavigationMixin(LightningElement) {
  //variables added by Bhavya for Document Translation starts here

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

   //variables added by Bhavya for Document Translation ends here
  imageUrls = [];
  showimages = false;
  isModalOpen = false;
  selectedimageid;
  imageselected = false;
  imagebuttonlabel = 'Select Image';
  @api showfooterdetails = false;
  @api sectiontype;
  @api documenttemplaterecord;
  @api rowcount;
  @api sectionrecordid;
  @api isDisabled = false;
  @api selectedObjectName;
  @api pdfLinks;

  richtextVal = 'All Right Reserved.';
  sectionItemsToselect = [{ label: 'Display Page Number Sequence', value: 'Display Page Number Sequence' }];
  @track value = [];
  displaypagesequence = false;
  countoptions = [{ label: '1', value: '1' }, { label: '2', value: '2' }, { label: '3', value: '3' }];
  columnvalue;
  columnvalueList = [];
  footerSectionsMap = [];
  oldFooterColumnList = {};

  @track Recorddetailsnew = {
    Name: '',
    DxCPQ__Section_Content__c: '',
    DxCPQ__DisplaySectionName__c: false,
    DxCPQ__New_Page__c: false,
    DxCPQ__Document_Template__c: '',
    DxCPQ__Sequence__c: 0,
    DxCPQ__Type__c: '',
    Id: '',
    DxCPQ__Document_Clause__c: ''
  };

  @wire(getContentVersions) wiredcontentversions({ error, data }) {
    if (data) {
      if (data != null) {
        data.forEach((val) => {
          this.imageUrls.push({ Id: val.Id, URL: '/sfc/servlet.shepherd/version/download/' + val.Id, title: val.Title });
        });
        this.showimages = true;
      }
    }
    else if (error) { }
  }

  @api handleActivateTemplate(isActive) {
    this.isDisabled = isActive;
  }

  connectedCallback() {
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

  handlecolumncomboChange(event) {
    this.columnvalueList = [];
    this.columnvalue = event.detail.value;
    this.handlecolumnsClass(this.columnvalue);
    if (this.footerSectionsMap.length > 0) {
      if (this.footerSectionsMap.length < this.columnvalue) {
        for (var i = this.footerSectionsMap.length; i < this.columnvalue; i++) {
          if (this.oldFooterColumnList[i]) {
            this.footerSectionsMap.push(this.oldFooterColumnList[i]);
          }
          else {
            this.columnvalueList.push(i);
            this.footerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i , "columnCount": this.columnvalue, "footerVal": '' })
          }
        }
      }
      else if (this.footerSectionsMap.length > this.columnvalue) {
        this.handleColumnRemoval();
      }
    }
    else {
      for (var i = 0; i < this.columnvalue; i++) {
        this.columnvalueList.push(i);
        this.footerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i, "columnCount": this.columnvalue, "footerVal": '' })
      }
    }
    let refData = {
      "0":{"0":""},
      "1":{"0":"Left", "1":"Right"},
      "2":{"0":"Left", "1":"Center", "2":"Right"}
    }
    this.footerSectionsMap.forEach(item => {
        item.columnCount = this.columnvalue;
        item.footerVal = refData[this.columnvalue - 1][item.indexvar];
    });
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  /* Footer Changes Start by Rahul*/
  handleColumnRemoval() {
    let headerColumnsList = {};
    let size = 0;

    for (let i = 0; i < this.footerSectionsMap.length; i++) {
      let tempColumnDetail = this.footerSectionsMap[i];
      if (tempColumnDetail.indexvar < this.columnvalue) {
        headerColumnsList[tempColumnDetail.indexvar] = tempColumnDetail;
        size += 1;
      }
      else {
        this.oldFooterColumnList[tempColumnDetail.indexvar] = tempColumnDetail;
      }
    }

    this.footerSectionsMap = [];
    for (let i = 0; i < size; i++) {
      if (headerColumnsList[i]) {
        this.footerSectionsMap.push(headerColumnsList[i]);
      }
    }
    let refData = {
      "0":{"0":""},
      "1":{"0":"Left", "1":"Right"},
      "2":{"0":"Left", "1":"Center", "2":"Right"}
    }
    this.footerSectionsMap.forEach(item => {
        item.columnCount = this.columnvalue;
        item.footerVal = refData[this.columnvalue - 1][item.indexvar];
    });
  }
  /* Footer Changes End by Rahul */

  handlecolumnsClass(columncount) {
    this.classvar = 'slds-col slds-size_1-of-' + columncount;
  }

  saverichtextfooter(event) {
    var data = event.detail;
    this.footerSectionsMap.forEach((loopvar, index) => {
      if (loopvar.indexvar == data.indexvar) {
        this.footerSectionsMap.splice(index, 1);
        this.footerSectionsMap.push(data);
      }
    });
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  handlecheckboxChange(event) {
    const mystring = JSON.stringify(event.detail.value);
    if (mystring.includes('Display Page Number Sequence')) {
      this.displaypagesequence = true;
    }
    else {
      this.displaypagesequence = false;
    }
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  @api loadsectionsvaluesforCreation() {
    this.showfooterdetails = true;
    this.columnvalue = null;
    this.columnvalueList = [];
    this.footerSectionsMap = [];
    this.value = [];
    this.Recorddetailsnew = {
      Name: '', DxCPQ__Section_Content__c: '', DxCPQ__DisplaySectionName__c: false,
      DxCPQ__New_Page__c: false,
      DxCPQ__Document_Template__c: '',
      DxCPQ__Sequence__c: 0,
      DxCPQ__Type__c: '',
      Id: '',
      DxCPQ__Document_Clause__c: ''
    };
    const saveEvent = new CustomEvent('datasaved', {detail: true });
    this.dispatchEvent(saveEvent);
  }

  @api loadsectionvaluesforedit(recordID) {
    this.showfooterdetails = true;
    gettemplatesectiondata({ editrecordid: recordID })
      .then(result => {
        if (result != null) {
          var sectioncontent = JSON.parse(result.DxCPQ__Section_Content__c);
          
          /* Fix for Header Onload Alignment by Rahul*/
          let sectionsMapTemp = sectioncontent.sectionsContent;
          sectionsMapTemp.sort((a, b) => {
            return a.indexvar - b.indexvar;
          });
          this.footerSectionsMap = sectionsMapTemp;
          /* Fix for Header Onload Alignment by Rahul*/

          this.columnvalue = sectioncontent.sectionsCount;
          this.translateEnabled = this.columnvalue > 0? false: true;
          this.handlecolumnsClass(this.columnvalue);

          this.displaypagesequence = sectioncontent.displaypagesequence;
          this.template.querySelectorAll('lightning-checkbox-group ').forEach(element => {
            if (this.displaypagesequence == true) {
              this.value.push('Display Page Number Sequence');
            }
          });
          const saveEvent = new CustomEvent('datasaved', {detail: true });
          this.dispatchEvent(saveEvent);
        }
      })
      .catch(error => {
        console.log('error loadsectionvaluesforedit footer' + JSON.stringify(error));
      })
  }

  handlesectionsave(event) {
    this.Recorddetailsnew.Name = this.sectiontype;
    var currecid = this.sectionrecordid;
    if (this.footerSectionsMap.length > 0) {
      this.footerSectionsMap.forEach((loopvar) => {
        var sectionval = loopvar.value;
        if (sectionval.includes('img') && !sectionval.includes('style')) {
          const styletag = 'style=\"max-height:35px; max-width:100%; height:35px; margin:10px 20px;\"';
          sectionval = sectionval.slice(0, sectionval.lastIndexOf('"') + 1) +
            ' ' + styletag + sectionval.slice(sectionval.lastIndexOf('"') + 1, sectionval.length);
          loopvar.value = sectionval;
        }
      });
      var obj = {};
      obj.sectionsCount = this.columnvalue;
      obj.sectionsContent = this.footerSectionsMap;
      obj.displaypagesequence = this.displaypagesequence;
      this.Recorddetailsnew.DxCPQ__Section_Content__c = JSON.stringify(obj);
    }

    if (currecid != '' && this.sectionrecordid.indexOf('NotSaved') == -1) {
      this.Recorddetailsnew.Id = this.sectionrecordid;
    }
    this.Recorddetailsnew.DxCPQ__Sequence__c = this.rowcount;
    this.Recorddetailsnew.DxCPQ__Type__c = this.sectiontype;
    this.Recorddetailsnew.DxCPQ__Document_Template__c = this.documenttemplaterecord.Id;

    if (this.Recorddetailsnew.Name != '' && this.Recorddetailsnew.Name != null) {
      saveDocumentTemplateSectionDetails({ Recorddetails: this.Recorddetailsnew })
        .then(result => {
          if (result != null) {
            this.savedRecordID = result;
            this.sectionrecordid = this.savedRecordID.Id;
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
          console.log('Footer Saving Error' + JSON.stringify(error));
        })
    }
    else {
      const Errormsg = new ShowToastEvent({
        title: 'Error',
        message: 'Please Enter Name',
        variant: 'Error',
      });
      this.dispatchEvent(Errormsg);
    }
  }

    handlehelp(){
      let relatedObjectsMap = this.pdfLinks.find(item => item.MasterLabel === 'Footer');
      let pdfUrl = relatedObjectsMap ? relatedObjectsMap.DxCPQ__Section_PDF_URL__c : null;
          const config = {
        type: 'standard__webPage',
        attributes: {
            url: pdfUrl
          }
    };
    this[NavigationMixin.Navigate](config);
  }

    // code added by Bhavya for Document translation
    handleTranslate(event) {
      this.extractedWords = [];
      this.extractWords();
      this.isTranslateModalOpen = true;
      this.template.querySelector('c-modal').show();

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
  
  //code added by Bhavya for extracting the merge fields along with the tokens
  extractWords(){
    let regex = /<<([^>]+?)>>|({![^}]+?})/g;

    this.footerSectionsMap.forEach(section => {
        let decodedValue = section.value.replace(/&lt;/g, '<').replace(/&gt;/g, '>');
        let m;
        while ((m = regex.exec(decodedValue)) !== null) {
            if (m.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            if (m[1]) {
                this.extractedWords.push(m[1]);
            } else if (m[2]) {
                this.extractedWords.push(m[2]);
            }
        }
    });
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

  handlerowlevelmerge(event) {
    this.selectedRowIndex = event.currentTarget.dataset.index;
    this.isTranslateModalOpen = false;
    this.rowlevelmerge = true;
    this.template.querySelector('c-modal').show();
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
}