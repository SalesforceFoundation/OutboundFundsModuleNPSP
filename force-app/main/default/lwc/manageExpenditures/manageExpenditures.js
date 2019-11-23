import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ManageExpenditures extends NavigationMixin(LightningElement) {
  @api parentId;
  @api parentName;
  @track numbers = [1];

  addRow() {
    this.numbers.push(this.numbers[this.numbers.length - 1] + 1);
  }

  handleDelete(event) {
    if (this.numbers.length > 1) {
      this.numbers.splice(this.numbers.indexOf(event.detail), 1);
    }
  }

  handleCancel() {
    // TODO: debug this
    this[NavigationMixin.Navigate]({
      type: "standard__RecordPage",
      attributes: {
        "recordId": this.parentId,
        "objectApiName": "outfunds__Disbursement__c",
        "actionName": "view"
      },
    });
  }
}
