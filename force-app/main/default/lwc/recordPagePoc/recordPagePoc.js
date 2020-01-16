import { LightningElement, api, wire, track } from "lwc";
import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";

export default class RecordPagePoc extends LightningElement {
  @api recordId;
  @track disbursement;
  @track error;

  @wire(getDisbursement, { disbursementId: "$recordId" })
  wiredDisbursement({ error, data }) {
    if (data) {
      this.disbursement = JSON.stringify(data);
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.disbursement = undefined;
    }
  }
}
