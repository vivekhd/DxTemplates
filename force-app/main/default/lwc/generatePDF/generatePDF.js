import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pdfObjectdetails from '@salesforce/apex/PdfDisplay.getObjectDetails';
import getDomainUrl from '@salesforce/apex/PdfDisplay.getDomainUrl';
export default class GeneratePDF extends  NavigationMixin(LightningElement)  {

@api recordId;
objectApiName;
objectLabel;
domainURL;

connectedCallback()
{
    this.getDomainBaseURL();

    pdfObjectdetails({recordId:this.recordId})
    .then(result=>{
      
        this.objectApiName = result.objectName;
        this.objectLabel = result.objectLabel;
    })
    .catch(error=>{
        console.log('error is occured in getting obj Name');
});

}

getDomainBaseURL()
{
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
        console.log("object name in gen PDF " + this.objectApiName);      

        // Navigate to the Aura component
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: `/lightning/cmp/DxCPQ__NavigateToDocument?c__recordId=${this.recordId}&c__refreshKey=${this.refreshKey}`
        //     }
        // });


        // Changes by Kapil - Fix for refresh previous record data onload
        // Navigate to the Aura component
        const anchor = document.createElement('a');
        let url = `/lightning/cmp/DxCPQ__NavigateToDocument?c__recordId=${this.recordId}`;
        anchor.href = this.domainURL + url; 
        anchor.target = '_self';
        anchor.click();  
}

}