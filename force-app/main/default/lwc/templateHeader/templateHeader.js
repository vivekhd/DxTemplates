import { LightningElement, wire, api, track } from 'lwc';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';
import { NavigationMixin } from 'lightning/navigation';

export default class TemplateHeader extends NavigationMixin(LightningElement) {

  columnvalue;
  @api pdfLinks;
  @api rowcount;
  @api sectiontype;
  columnvalueList = [];
  @api selectedObjectName;
  @api sectionrecordid;
  @api isDisabled = false;
  headerSectionsMap = [];
  @api documenttemplaterecord;
  @api showheaderdetails = false;
  classvar = 'slds-col slds-size_1-of-3';
  popUpMessage;
  oldHeaderColumnList = {};
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
            this.headerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i })
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
        this.headerSectionsMap.push({ "value": "", "indexvar": i, "key": (new Date()).getTime() + ":" + i })
      }
    }
  }

  /* Header Changes Start*/
  handleColumnRemoval() {
    let headerColumnsList = {};
    let size = 0;

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
    for (let i = 0; i < size; i++) {
      if (headerColumnsList[i]) {
        this.headerSectionsMap.push(headerColumnsList[i]);
      }
    }
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
  }

  @api loadsectionsvaluesforCreation() {
    this.showheaderdetails = true;
    this.columnvalue = null;
    this.columnvalueList = [];
    this.headerSectionsMap = [];

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
    this.showheaderdetails = true;
    gettemplatesectiondata({ editrecordid: recordID })
      .then(result => {
        if (result != null) {
          var sectioncontent = JSON.parse(result.DxCPQ__Section_Content__c);
          this.columnvalue = sectioncontent.sectionsCount;

           /* Fix for Header Onload Alignment by Rahul*/
          let sectionsMapTemp = sectioncontent.sectionsContent;
          sectionsMapTemp.sort((a, b) => {
            return a.indexvar - b.indexvar;
          });
          this.headerSectionsMap = sectionsMapTemp;
           /* Fix for Header Onload Alignment by Rahul*/
           
          this.handlecolumnsClass(this.columnvalue);
        }
      })
      .catch(error => {
        console.log('error loadsectionsectionvaluesforedit header' + JSON.stringify(error));
      })
  }

  handlesectionsave(event) {
    this.Recorddetailsnew.Name = this.sectiontype;
    var currecid = this.sectionrecordid;
    if (this.headerSectionsMap.length > 0) {
      this.headerSectionsMap.forEach((loopvar) => {
        var sectionval = loopvar.value;
        if (sectionval.includes('img') && !sectionval.includes('style')) {
          const styletag = 'style=\"max-height:100% ; max-width:100%; height:40px; margin:10px 20px;\"';
          sectionval =  sectionval.slice(0, sectionval.lastIndexOf('"') + 1) + ' ' + styletag + sectionval.slice(sectionval.lastIndexOf('"') + 1, sectionval.length);
          loopvar.value = sectionval;
        }
      });
      var obj = {};
      obj.sectionsCount = this.columnvalue;
      obj.sectionsContent = this.headerSectionsMap;
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
            var firecustomevent = new CustomEvent('savesectiondata', { detail: this.savedRecordID });
            this.dispatchEvent(firecustomevent);
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
}