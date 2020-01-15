import { LightningElement, track, api } from "lwc";

export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  @api parentId;
  @api parentName;
  @api parentAmount;
  @api gauExpendituresString;

  @track gauExpenditures;
  @track remainingAmount;
  @track remainingAmountStatus;
  @track disableSave;

  connectedCallback() {
    let rowId = 1;
    this.gauExpenditures = JSON.parse(this.gauExpendituresString);
    this.gauExpenditures.forEach(function(eachExpenditure) {
      eachExpenditure.rowId = rowId++;
    });
    this.updateRemainingAmount();
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
    this.updateRemainingAmount();
  }

  updateRemainingAmount() {
    let usedAmount = this.gauExpenditures.reduce(function(
      total,
      eachExpenditure
    ) {
      if (eachExpenditure.amount) {
        return parseFloat(total) + parseFloat(eachExpenditure.amount);
      }
      return parseFloat(total);
    },
    0);

    this.remainingAmount = this.parentAmount - usedAmount;
    if (this.remainingAmount < 0) {
      this.remainingAmountStatus = "INVALID";
      this.disableSave = true;
    } else {
      this.remainingAmountStatus = "VALID";
      this.disableSave = false;
    }
  }
}
