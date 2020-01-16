import { LightningElement, api, track } from "lwc";
import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";

export default class RecordPagePoc extends LightningElement {
  @api recordId;
  @track disbursement;
  @track error;

  connectedCallback() {
    getDisbursement({ disbursementId: this.recordId })
      .then(result => {
        this.disbursement = JSON.stringify(result);
        this.error = undefined;
      })
      .catch(error => {
        this.disbursement = undefined;
        this.error = error;
      });
  }
}
