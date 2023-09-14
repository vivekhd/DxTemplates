import { LightningElement, api } from 'lwc';
import saveData from '@salesforce/apex/SaveDocumentTemplatesection.saveData';

export default class HiddenComponent extends LightningElement {

    @api htmlContent
    tableHeaderDuplicate = [];
    headerElementStyle = '';

    connectedCallback() {
        console.log(this.htmlContent);
    }

    @api callFromComponent(recordId, data, headBgClr, headFontClr, headFontSize, headFontFam, slno) {
        this.headerElementStyle = 'width:10px; border: 1px solid black ; background-color:' + headBgClr + ' ; color:' + headFontClr + '; font-size:' + headFontSize + '; font-family:' + headFontFam + '; text-align: center;';
        this.tableHeaderDuplicate = [...data];
        if(slno){this.tableHeaderDuplicate.unshift('Sl No');}
        
        setTimeout(() => {
            console.log(this.template.querySelector('[data-id="header"]').innerHTML);
            saveData({ dataFrom: this.template.querySelector('[data-id="header"]').innerHTML , recordId : recordId})
            .then(result => {
                    console.log('Successfull Header Framework', result);
            })
            .catch(error => {
                console.log('Error Header Framework', error);
            });
        });
    }  
}