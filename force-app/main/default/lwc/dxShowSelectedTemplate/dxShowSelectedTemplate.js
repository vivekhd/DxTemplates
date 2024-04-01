import { LightningElement, api,wire,track} from 'lwc';
import getTemplateSections from '@salesforce/apex/DisplayPDFController.getTemplateSections';
import getTemplateSectionsMulRecords from '@salesforce/apex/DisplayPDFController.getTemplateSectionsMulRecords';
import generateDocument from '@salesforce/apex/DisplayPDFController.generateDocument';
import generatePDFAttachment from '@salesforce/apex/DisplayPDFController.generatePDFAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';

export default class DxShowSelectedTemplate extends LightningElement {
    @api showHeader;
    @api showFooter;
    @api templateId;
    @api quoteId;
    @api objectRecordId;
    @api objectName;
    pdfheaderfooter;
    
    templatesectionid;
    sectionContentArr=[];
    headerArr =[];
    @track head1='';
    @track head2='';
    @track head3='';
    @track foot1='';
    @track foot2='';
    @track foot3='';
    footerArr=[];
    showrelatedobjectsdata=false;
    isModalOpen=false;
    isLoaded=false;
    isLoaded2=false;
    downloadURL;
    isSectionContentLoaded=false;
    headerfooter={};
    showpreviewbutton=false;
    showpreview=false;
    popUpMessage;
  

    @wire(getAllPopupMessages) 
        allConstants ({error, data}) {
            if (data) {
                this.popUpMessage = data;
                console.log('Success');
            } else {
                this.error = error;
            }
        }

    connectedCallback() {
        this.isLoaded=true;
        console.log('objectRecordId-',this.objectRecordId);
        getTemplateSections({templateId : this.templateId, recordId:this.objectRecordId, objectApiName: this.objectName}).then((result) => {
            this.isLoaded=false;

            if(result && result.length>0){
                result.forEach(tempSec=>{
                    
                    if(tempSec.DxCPQ__Type__c=='Context' || tempSec.DxCPQ__Type__c=='Table' || tempSec.DxCPQ__Type__c=='Clause' ){
                        
                        let tempObj={};
                        tempObj.index = tempSec.DxCPQ__Sequence__c;
                        tempObj.isRelated=false;
                        tempObj.isContext=true;
                        tempObj.content=tempSec.DxCPQ__Section_Content__c;
                        this.sectionContentArr.push(tempObj);
                    }else if(tempSec.DxCPQ__Type__c=='Related Objects')
                    {
                        let tempObj={};
                        tempObj.index = tempSec.DxCPQ__Sequence__c;
                        tempObj.isRelated=true;
                        tempObj.isContext=false;
                        tempObj.templatesectionid=tempSec.Id;
                        this.sectionContentArr.push(tempObj);
                    }
                    else if(tempSec.DxCPQ__Type__c=='Header')
                    {
                        let index;
                        this.showHeader = true;
                        var seccon= JSON.parse(tempSec.DxCPQ__Section_Content__c);
                        this.headerArr = seccon.sectionsContent;
                        
                        setTimeout(() => {
                        let allHeaders = this.template.querySelectorAll('[data-indexhead]');
                        let count =0;
                        let lst =[];
                        lst.push('');
                        lst.push('');
                        lst.push('');
                        for(let i=0;i<seccon.sectionsContent.length;i++)
                        {
                            if(seccon.sectionsContent[i].value=='')
                            {
                                index = seccon.sectionsContent[i].indexvar;
                                lst[index]='<p> </p>';
                            }
                             else
                             {
                                index = seccon.sectionsContent[i].indexvar;
                                lst[index] = seccon.sectionsContent[i].value;
                             }
                            count++;
                        }
                        while(count<3)
                        {
                            lst[count]='<p> </p>';
                            count++;
                        }
                        let allHeaders1 = this.template.querySelector('[data-indexhead1]');
                        let allHeaders2 = this.template.querySelector('[data-indexhead2]');
                        let allHeaders3 = this.template.querySelector('[data-indexhead3]');
                        
                        
                        allHeaders1.innerHTML =lst[0];
                        allHeaders2.innerHTML =lst[1];
                        allHeaders3.innerHTML =lst[2];
                        }, 100);
                        this.headerfooter.header = seccon;
                    }
                    else if(tempSec.DxCPQ__Type__c=='Footer')
                    {
                        var seccon= JSON.parse(tempSec.DxCPQ__Section_Content__c);
                        this.showFooter = true;
                        var obj = {};
                        obj.footertext=seccon.footertext;
                        obj.displaypagesequence = seccon.displaypagesequence;
                        this.footerArr =  seccon.sectionsContent;
                        
                        setTimeout(() => {
                        
                        let count =0;
                        let lst =[];
                        lst.push('');
                        lst.push('');
                        lst.push('');
                        for(let i=0;i<seccon.sectionsContent.length;i++) {
                            if (seccon.sectionsContent[i].value == '') {
                                let index = seccon.sectionsContent[i].indexvar;
                                lst[index] ='<p> </p>';
                            }
                            else {
                                let index = seccon.sectionsContent[i].indexvar;
                                lst[index] =seccon.sectionsContent[i].value;
                            }
                            count++;
                        }
                        while(count<3) {
                            lst[count]='<p> </p>';
                            count++;
                        }
                        let allFotter1 = this.template.querySelector('[data-indexfoot1]');
                        let allFotter2 = this.template.querySelector('[data-indexfoot2]');
                        let allFotter3 = this.template.querySelector('[data-indexfoot3]');
                        
                        allFotter1.innerHTML =lst[0];
                        allFotter2.innerHTML =lst[1];
                        allFotter3.innerHTML =lst[2];
                        }, 100);
                        this.headerfooter.footer= seccon;
                    }
                })                                
            }
        }).catch((err) => {
            // this.isLoaded=false;
            console.log('Error Section Contentes'+ JSON.stringify(err));
        });
    }

    renderedCallback(){
        this.isSectionContentLoaded=true; 
            let index = 0;
            this.sectionContentArr.forEach(obj=>{
                let elementDiv = this.template.querySelector(`[data-id="${index}"]`);
                if(obj.isContext==true){
                    elementDiv.innerHTML=obj.content;
                }
                index++;
            })

   
    Promise.all([
      loadStyle(this, rte_tbl + '/rte_tbl1.css'),
    ])
      .then(() => {
      })
      .catch(error => {
      });
    }

    @api
    handlePDF(){
        this.isLoaded2=true;
        const container = this.template.querySelector('.wholecontent');
        var headfooterstr=JSON.stringify(this.headerfooter);

        generateDocument({templateId : this.templateId, quoteId:this.objectRecordId, pdfbody:container.innerHTML,pdfheaderfooter:headfooterstr}).then((result) => {
            
            console.log('this is result'+JSON.parse(JSON.stringify(result)));
            console.log('this is result',result);
            if(result && result.length>0){
                this.handleAttachment(result);
            }
            
        }).catch((err) => {
            this.isLoaded2=false;
            console.log('this is error handlePDF',err);
        });
        
    }

    handleAttachment(documentid)
    {
        generatePDFAttachment({documentid : documentid, quoteId:this.objectRecordId}).then((result) => {
           if(result && result.length>0){
                this.isLoaded=false;
                this.downloadURL = '/servlet/servlet.FileDownload?file='+result;
                this.showpreviewbutton=true;
                var docdetailsobj={documentid:documentid,downloadURL:this.downloadURL,attachmentid:result};

                var firecustomevent = new CustomEvent('pdfgeneration', { detail:docdetailsobj});
                this.dispatchEvent(firecustomevent);

                const event4 = new ShowToastEvent({
                    title: 'Success',
                    message: this.popUpMessage.DXSHOWSELECTEDTEMPLATE_PDF,
                    variant: 'success',
                    });
    
                    this.dispatchEvent(event4);
                    this.isLoaded2=false;
            }
            
        }).catch((err) => {
            console.log('this is error handleAttachment',err);
        });
    }

    displayChildContent(event){
        let index = event.detail.index;
        let content = event.detail.content;
        let elementDiv = this.template.querySelector(`[data-id="${index}"]`);
        elementDiv.innerHTML=content.innerHTML;
    }  

    /* Commented by Rahul - not intended in this release */
    handleClauseContent(event){
        /*let elediv = this.template.querySelector('.clause');
        var productClausesMap={};
        productClausesMap = (event.detail.content);
        productClausesMap.forEach( (val,index) => {
            console.log('this.val======',val);
            elediv.innerHTML+= '<b>'+val.name+'</b><br/>';

            var clausebody=[];
            clausebody = val.bodycontent;
            clausebody.forEach( (val,index) => {
                elediv.innerHTML+= clausebody[index];
            });
        });*/
    } 

}