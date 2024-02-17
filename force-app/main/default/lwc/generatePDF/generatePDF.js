import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pdfObjectdetails from '@salesforce/apex/PdfDisplay.getObjectDetails';
import getDomainUrl from '@salesforce/apex/PdfDisplay.getDomainUrl';
export default class GeneratePDF extends  NavigationMixin(LightningElement)  {

    @api recordId;
    objectApiName;
    objectLabel;
    domainURL;

    connectedCallback() {
        this.getDomainBaseURL();
        pdfObjectdetails({
                recordId: this.recordId
            })
            .then(result => {
                this.objectApiName = result.objectName;
                this.objectLabel = result.objectLabel;
            })
            .catch(error => {});

    }

    getDomainBaseURL() {
        getDomainUrl()
            .then((result) => {
                if (result) {
                    this.domainURL = result;
                }
            })
            .catch((error) => {
                console.error('Error retrieving getDomainUrl message:', error.message);
            });
    }

    handleClick() {
        const anchor = document.createElement('a');
        let url = `/lightning/cmp/DxCPQ__NavigateToDocument?c__recordId=${this.recordId}`;
        anchor.href = this.domainURL + url;
        anchor.target = '_self';
        anchor.click();
    }


}