import { LightningElement, track, api } from "lwc";

export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  @api parentId;
  @api parentName;
  @api gaueString;

  @track gauExpenditures;
  @track numbers = [1];

  connectedCallback() {
    let rowId = 1;
    this.gauExpenditures = JSON.parse(this.gaueString);
    this.gauExpenditures.forEach(function(eachExpenditure) {
      eachExpenditure.rowId = rowId++;
    });
  }

  addRow() {
    let rowId = this.gauExpenditures[this.gauExpenditures.length - 1].rowId + 1;
    this.gauExpenditures.push({ rowId: rowId });
  }

  handleUpdate(event) {
    let index = this.gauExpenditures
      .map(expenditure => {
        return expenditure.rowId;
      })
      .indexOf(event.detail.rowId);

    switch (event.type) {
      case "update":
        this.gauExpenditures[index] = event.detail;
        break;
      case "delete":
        if (this.gauExpenditures.length > 1) {
          this.gauExpenditures.splice(index, 1);
        }
        break;
      default:
        break;
    }
  }
}
