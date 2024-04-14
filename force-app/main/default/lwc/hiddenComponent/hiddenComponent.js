import { LightningElement, api } from 'lwc';
import saveData from '@salesforce/apex/SaveDocumentTemplatesection.saveData';
import createLog from '@salesforce/apex/LogHandler.createLog';
export default class HiddenComponent extends LightningElement {

    @api htmlContent
    tableHeaderDuplicate = [];
    headerElementStyle = ''

    @api callFromComponent(recordId, data, headBgClr, headFontClr, headFontSize, headFontFam, slno) {
        this.headerElementStyle = 'width:10px; border: 1px solid black ; background-color:' + headBgClr + ' ; color:' + headFontClr + '; font-size:' + headFontSize + '; font-family:' + headFontFam + '; text-align: center;';
        this.tableHeaderDuplicate = [...data];
        if(slno){this.tableHeaderDuplicate.unshift('Sl No');}
        
        setTimeout(() => {
            saveData({ dataFrom: this.template.querySelector('[data-id="header"]').innerHTML , recordId : recordId})
            .then(result => {result;  })
            .catch(error => {
                createLog({recordId:null, className:'hiddenComponent LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
            })
        });
    }
}