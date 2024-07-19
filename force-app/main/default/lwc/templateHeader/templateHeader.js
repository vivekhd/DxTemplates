import { LightningElement, wire, api, track } from 'lwc';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';
import createUpdateMethod from '@salesforce/apex/LanguageTranslatorClass.createUpdateMethod';
import deleteMethod from '@salesforce/apex/LanguageTranslatorClass.deleteMethod';
import selectedLangMethod from '@salesforce/apex/LanguageTranslatorClass.selectedLangMethod';
import getAllUserLanguages from '@salesforce/apex/LanguageTranslatorClass.getAllUserLanguages';
import createLog from '@salesforce/apex/LogHandler.createLog';
import currectUserLang from '@salesforce/apex/LanguageTranslatorClass.currectUserLang';
import { NavigationMixin } from 'lightning/navigation';

export default class TemplateHeader extends NavigationMixin(LightningElement) {

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

  columnvalue;
  columnfirstvalue;
  @api pdfLinks;
  @api rowcount;
  @api sectiontype;
  columnvalueList = [];
  columnfirstvalueList=[];
  @api selectedObjectName;
  @api sectionrecordid;
  @api isDisabled = false;
  headerMap =[];
  headerSectionsMap = [];
  headerFirstSectionsMap=[];
  @api documenttemplaterecord;
  @api showheaderdetails = false;
  classvar = 'slds-col slds-size_1-of-3';
  classfirstvar = 'slds-col slds-size_1-of-3';
  showfirstpageheader=false;
  popUpMessage;
  oldHeaderColumnList = {};
  oldHeaderFirstColumnList={};
  whereCondition ="";
  whereClause = " IsActive__c = true";

  Recorddetailsnew = {
    Name: '', DxCPQ__Section_Content__c: '', DxCPQ__DisplaySectionName__c: false,
    DxCPQ__New_Page__c: false,
    DxCPQ__Document_Template__c: '',
    DxCPQ__Sequence__c: 0,
    DxCPQ__Type__c: '',
    Id: '',
    DxCPQ__Document_Clause__c: ''
  };
  countoptions = [{ label: '1', value: '1' }, { label: '2', value: '2' }, { label: '3', value: '3' }];


  @wire(getAllPopupMessages)
  allConstants({ error, data }) {
    if (data) {
      this.popUpMessage = data;
    } else {
      this.error = error;
    }
  }

  connectedCallback() {
    this.whereCondition ="DxCPQ__Document_Template__r.DxCPQ__Related_To_Type__c = " +"\'"+this.selectedObjectName+"\'"+" AND DxCPQ__Type__c = "+"\'"+this.sectiontype+"\'";
    this.whereClause = this.whereCondition;
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

  handleDiffHeader(event){
    this.showfirstpageheader = event.detail.checked;
  }

  handlefirstcolumncomboChange(event){
    this.columnfirstvalueList = [];
    this.columnfirstvalue = event.detail.value;
    this.handlefirstcolumnsClass(this.columnfirstvalue);
    if (this.headerFirstSectionsMap.length > 0) {
      if (this.headerFirstSectionsMap.length < this.columnfirstvalue) {
        for (var i = this.headerFirstSectionsMap.length; i < this.columnfirstvalue; i++) {
          if (this.oldHeaderFirstColumnList[i]) {
            this.headerFirstSectionsMap.push(this.oldHeaderFirstColumnList[i]);
          }
          else {
            this.columnfirstvalueList.push(i);
            this.headerFirstSectionsMap.push({ "value": "", "indexvar": i+3, "columnFirstCount":this.columnfirstvalue, "key": (new Date()).getTime() + ":" + i, "headerVal": "" })
            //this.headerSectionsMap.push({ "value": "", "indexvar": i+3,  "key": (new Date()).getTime() + ":" + i })
          }
        }
      }
      else if (this.headerFirstSectionsMap.length > this.columnfirstvalue) {
        this.handleColumnRemoval();
      }
    }
    else {
      for (var i = 0; i < this.columnfirstvalue; i++) {
        this.columnfirstvalueList.push(i);
        this.headerFirstSectionsMap.push({ "value": "", "indexvar": i+3, "columnFirstCount":this.columnfirstvalue, "key": (new Date()).getTime() + ":" + i, "headerVal": "" })
        //this.headerSectionsMap.push({ "value": "", "indexvar": i+3, "key": (new Date()).getTime() + ":" + i })
      }
    } 
    //this.headerSectionsMap.push (this.headerFirstSectionsMap) 
    let refData = {
      "0":{"0":""},
      "1":{"0":"Left", "1":"Right"},
      "2":{"0":"Left", "1":"Center", "2":"Right"}
    }
    this.headerFirstSectionsMap.forEach(item => {
        item.columnFirstCount = this.columnfirstvalue;
        item.headerVal = refData[this.columnfirstvalue - 1][item.indexvar-3];
    });
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  handlefirstcolumnsClass(columncount) {
    this.classfirstvar = 'slds-col slds-size_1-of-' + columncount;
  }

  handlecolumnsClass(columncount) {
    this.classvar = 'slds-col slds-size_1-of-' + columncount;
  }

  handlecolumncomboChange(event) {
    this.columnvalueList = [];    
    this.columnvalue = event.detail.value;
    this.handlecolumnsClass(this.columnvalue);
    if (this.headerSectionsMap.length > 0) {
      if (this.headerSectionsMap.length < this.columnvalue) {
        for (var i = this.headerSectionsMap.length; i < this.columnvalue; i++) {
          if (this.oldHeaderColumnList[i]) {
            this.headerSectionsMap.push(this.oldHeaderColumnList[i]);
          }
          else {
            this.columnvalueList.push(i);          
            this.headerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i , "columnCount": this.columnvalue, "headerVal": ''})
          }
        }
      }
      else if (this.headerSectionsMap.length > this.columnvalue) {
        this.handleColumnRemoval();
      }
    }
    else {
      for (var i = 0; i < this.columnvalue; i++) {
        this.columnvalueList.push(i);     
        this.headerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i , "columnCount": this.columnvalue, "headerVal": '' })
      }
    }
    //adding headval in headerSectionsMap
    let refData = {
      "0":{"0":""},
      "1":{"0":"Left", "1":"Right"},
      "2":{"0":"Left", "1":"Center", "2":"Right"}
    }
    this.headerSectionsMap.forEach(item => {
        item.columnCount = this.columnvalue;
        item.headerVal = refData[this.columnvalue - 1][item.indexvar];
    });
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
    //console.log('columnvalueList ---> ', this.columnvalueList);
    console.log('headerSectionsMap after column value changed ---> ', this.headerSectionsMap);
  }

  /* Header Changes Start*/
  handleColumnRemoval() {
    let headerColumnsList = {};
    let headerFirstColumnsList ={};
    let size = 0;
    const tempColumnfirstValue = +this.columnfirstvalue+3;

    for (let i = 0; i < this.headerFirstSectionsMap.length; i++) {
      let tempColumnDetail = this.headerFirstSectionsMap[i];
      // if (tempColumnDetail.indexvar < this.columnvalue && tempColumnDetail.uniqueFirst == null) {
      //   headerColumnsList[tempColumnDetail.indexvar] = tempColumnDetail;
      //   size += 1;
      // }
      if(tempColumnDetail.indexvar < tempColumnfirstValue){
        //headerColumnsList[tempColumnDetail.indexvar] = tempColumnDetail;
        let tempindexvar = +tempColumnDetail.indexvar-3;
        headerFirstColumnsList[tempindexvar] = tempColumnDetail;
        size += 1;
      }
      else {
        let tempindexvar = +tempColumnDetail.indexvar-3;
        this.oldHeaderFirstColumnList[tempindexvar] = tempColumnDetail;
      }
    }

    for (let i = 0; i < this.headerSectionsMap.length; i++) {
      let tempColumnDetail = this.headerSectionsMap[i];
      if (tempColumnDetail.indexvar < this.columnvalue) {
        headerColumnsList[tempColumnDetail.indexvar] = tempColumnDetail;
        size += 1;
      }
      else {
        this.oldHeaderColumnList[tempColumnDetail.indexvar] = tempColumnDetail;
      }
    }
    
    this.headerSectionsMap = [];
    this.headerFirstSectionsMap = [];
    for (let i = 0; i < 6; i++) {
      if (headerColumnsList[i]) {
        this.headerSectionsMap.push(headerColumnsList[i]);
      }
      if (headerFirstColumnsList[i]){
        //this.headerSectionsMap.push(headerColumnsList[i]);
        this.headerFirstSectionsMap.push(headerFirstColumnsList[i]);
      }
    }
    let headerVal='';
    let refData = {
      "0":{"0":""},
      "1":{"0":"Left", "1":"Right"},
      "2":{"0":"Left", "1":"Center", "2":"Right"}
    }
    this.headerSectionsMap.forEach(item => {
        item.columnCount = this.columnvalue;
        item.headerVal = refData[this.columnvalue - 1][item.indexvar];
    });
    this.headerFirstSectionsMap.forEach(item => {
        item.columnFirstCount = this.columnfirstvalue;
        item.headerVal = refData[this.columnfirstvalue - 1][item.indexvar];
    });
  }
  /* Header Changes End by Rahul */

  @api
  handleActivateTemplate(isActive) {
    this.isDisabled = isActive;
  }

  //Custom Event Method which will be called from templateHeaderType Child
  saverichtextheader(event) {
    var data = event.detail;
    this.headerSectionsMap.forEach((loopvar, index) => {
      if (loopvar.indexvar == data.indexvar) {
        this.headerSectionsMap.splice(index, 1);
        this.headerSectionsMap.push(data);
      }
    });
    this.headerFirstSectionsMap.forEach((loopvar, index) => {
      if (loopvar.indexvar == data.indexvar) {
        this.headerFirstSectionsMap.splice(index, 1);
        this.headerFirstSectionsMap.push(data);
      }
    });
    const saveEvent = new CustomEvent('datasaved', {detail: false });
    this.dispatchEvent(saveEvent);
  }

  @api loadsectionsvaluesforCreation() {
    this.showheaderdetails = true;
    this.columnvalue = null;
    this.columnfirstvalue = null;
    this.columnvalueList = [];
    this.columnfirstvalueList = [];
    this.headerSectionsMap = [];
    this.headerFirstSectionsMap = [];
    this.showfirstpageheader = false;

    this.Recorddetailsnew = {
      Name: '', DxCPQ__Section_Content__c: '', DxCPQ__DisplaySectionName__c: false,
      DxCPQ__New_Page__c: false,
      DxCPQ__Document_Template__c: '',
      DxCPQ__Sequence__c: 0,
      DxCPQ__Type__c: '',
      Id: '',
      DxCPQ__Document_Clause__c: ''
    };
  }

  @api loadsectionvaluesforedit(recordID) {
    const saveEvent = new CustomEvent('datasaved', {detail: true});
    this.dispatchEvent(saveEvent);
    this.showheaderdetails = true;
    this.headerSectionsMap = [];
    this.headerFirstSectionsMap = [];
    this.showfirstpageheader = false;
    gettemplatesectiondata({ editrecordid: recordID })
      .then(result => {
        if (result != null) {
          var sectioncontent = JSON.parse(result.DxCPQ__Section_Content__c);
          this.columnvalue = sectioncontent.sectionsCount;
          this.translateEnabled = this.columnvalue > 0? false: true;
          this.columnfirstvalue = sectioncontent.sectionsFirstCount;
          if (sectioncontent.sectionsFirstCount>0){
            this.showfirstpageheader = true;
          }
          //this.showfirstpageheader = true;
          setTimeout(() => { 
            try{
              this.template.querySelector('[data-id="uniqueheader"]').checked = this.showfirstpageheader; 
              // this.columnfirstvalue = sectioncontent.sectionsFirstContent;
              // this.template.querySelector('[data-id="firstcombobox"]').value = this.columnfirstvalue;
              //this.columnfirstvalue = sectioncontent.sectionsFirstContent;
              this.handlefirstcolumnsClass(this.columnfirstvalue);
            }
            catch(error){
              console.log('error in setTimeout for checked error >> ', error.message);
            }
          });

           /* Fix for Header Onload Alignment by Rahul*/
          let sectionsMapTemp = sectioncontent.sectionsContent;
          sectionsMapTemp.sort((a, b) => {
            return a.indexvar - b.indexvar;
          });
          let firstSectionsMap =[];
          let sectionsMap=[];
          sectionsMapTemp.forEach((sectionmap)=>{
            if (sectionmap.indexvar>2){
              firstSectionsMap.push(sectionmap)
            }
            else sectionsMap.push(sectionmap)
          })
          this.headerFirstSectionsMap= firstSectionsMap;
          this.headerSectionsMap = sectionsMap; 
          //this.headerSectionsMap = sectionsMapTemp;
           /* Fix for Header Onload Alignment by Rahul*/
          this.handlecolumnsClass(this.columnvalue);
          //this.handlefirstcolumnsClass(this.columnfirstvalue);
        }
      })
      .catch(error => {
        console.log('error loadsectionsectionvaluesforedit header' + JSON.stringify(error));
      })
  }

  //code added by Bhavya to check if the style attribute is present in the Img tag
  identifyStyleTag(str){
    const regex = /<img\b[^>]*\bstyle\s*=\s*["'][^"']*["']/i;
    return regex.test(str);
    
  }

  handlesectionsave(event) {
    this.Recorddetailsnew.Name = this.sectiontype;
    var currecid = this.sectionrecordid;
    this.headerMap = this.headerSectionsMap.concat(this.headerFirstSectionsMap);
    if (this.headerMap.length > 0) {
      this.headerMap.forEach((loopvar) => {

        var sectionval = loopvar.value;
        if (sectionval.includes('img') && !this.identifyStyleTag(sectionval)) {
          const styleTag = 'style="max-height:100%; max-width:100%; width:80%; margin:0 50px 0 0;"';
          sectionval = sectionval.replace(/(<img\b[^>]*)(style\s*=\s*["'][^"']*["'])?([^>]*>)/i, (match, p1, p2, p3) => {
              if (p2) {
                  return `${p1}${p2.slice(0, -1)}; ${styleTag.slice(7)}`;
              }
              return `${p1} ${styleTag}${p3}`;
          });

          console.log('Updated sectionVal:', sectionval);
          loopvar.value = sectionval;
        }
      });

      console.log('this.headerMap after adding styles ---> ', this.headerMap);
      var obj = {};
      obj.sectionsCount = this.columnvalue;
      obj.sectionsFirstCount = this.columnfirstvalue;
      obj.sectionsContent = this.headerMap;
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
              message: 'Section "' + this.Recorddetailsnew.Name + '"' + this.popUpMessage.TEMPLATEHEADER_CREATED,
              variant: 'success',
            });

            this.dispatchEvent(event4);
            const saveEvent = new CustomEvent('datasaved', {detail: true });
            this.dispatchEvent(saveEvent);
            var firecustomevent = new CustomEvent('savesectiondata', { detail: this.savedRecordID });
            this.dispatchEvent(firecustomevent);
            this.translateEnabled = false;
          }
        })
        .catch(error => {
          console.log('Header Save Event Error', JSON.stringify(error));
        })
    }
    //this.template.querySelector('c-template-designer-cmp').showPreview = true;
  }

  handlehelp(){
    let relatedObjectsMap = this.pdfLinks.find(item => item.MasterLabel === 'Header');
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

    this.headerSectionsMap.forEach(section => {
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