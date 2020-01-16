import { LightningElement, track, api } from "lwc";
import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";
import upsertGauExpenditures from "@salesforce/apex/GauExpendituresManager.upsertGauExpenditures";
export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  @api recordId;
  @track parentId;
  @track parentName;
  @track parentAmount;

  @track gauExpenditures;
  @track remainingAmount;
  @track remainingAmountStatus;
  @track disableSave;
  @track error;

  connectedCallback() {
    getDisbursement({ disbursementId: this.recordId })
      .then(result => {
        this.parentId = result.recordId;
        this.parentName = result.name;
        this.parentAmount = result.amount;
        this.gauExpenditures = result.expenditures;
        this.updateRemainingAmount();
        this.error = undefined;
      })
      .catch(error => {
        this.disbursement = undefined;
        this.error = error;
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
    console.log("what");
    this.updateRemainingAmount();
    console.log("do");
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

  handleSave() {
    upsertGauExpenditures({
      expendituresString: JSON.stringify(this.gauExpenditures),
      disbursementId: this.parentId
    })
      .then(result => {
        console.log("success");
      })
      .catch(error => {
        console.log("error");
        this.disbursement = undefined;
        this.error = error;
      });
  }
}
