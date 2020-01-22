import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";
import upsertGauExpenditures from "@salesforce/apex/GauExpendituresManager.upsertGauExpenditures";
export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  @api objectApiName;
  @api recordId;
  @track parentId;
  @track parentName;
  @track parentAmount;

  @track gauExpenditures;
  @track remainingAmount;
  @track remainingAmountStatus;
  @track disableSave;
  @track error;
  @track isDisbursement = false;
  @track loaded = false;
  @track nonZeroAmount = false;

  connectedCallback() {
    this.isDisbursement = this.objectApiName === "outfunds__Disbursement__c";
    this.refreshList();
  }

  testChild() {
    console.log(this.template.querySelector("c-test-composition").print());
  }

  refreshList() {
    this.loaded = false;
    this.gauExpenditures = [];
    getDisbursement({ disbursementId: this.recordId })
      .then(result => {
        this.parentId = result.recordId;
        this.parentName = result.name;
        this.parentAmount = result.amount;
        this.nonZeroAmount = result.amount > 0;
        this.gauExpenditures = result.expenditures;
        this.padEmpty();
        this.updateRemainingAmount();
        this.error = undefined;
        this.loaded = true;
      })
      .catch(error => {
        this.disbursement = undefined;
        this.error = error;
        this.loaded = true;
      });
  }

  addRow() {
    let rowId =
      this.gauExpenditures.length > 0
        ? this.gauExpenditures[this.gauExpenditures.length - 1].rowId + 1
        : 1;
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
        this.gauExpenditures.splice(index, 1);
        this.padEmpty();
        break;
      default:
        break;
    }
    this.updateRemainingAmount();
  }

  padEmpty() {
    if (this.gauExpenditures.length === 0) {
      this.addRow();
    }
  }

  updateRemainingAmount() {
    let validRows = this.validateRows();
    this.disableSave = !validRows;
    if (this.disableSave) {
      return;
    }

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
    if (this.remainingAmount >= 0) {
      this.remainingAmountStatus = "VALID";
      this.disableSave = false;
    } else {
      this.remainingAmountStatus = "INVALID";
      this.disableSave = true;
    }
  }

  validateRows() {
    return [...this.template.querySelectorAll("c-gau-expenditure-row")].reduce(
      (validSoFar, childComponent) => {
        return validSoFar && childComponent.returnValidity();
      },
      true
    );
  }

  handleSave() {
    if (!this.validate()) {
      this.showErrorToast("Please remove any incomplete rows, then try again.");
      return;
    }
    if (
      this.gauExpenditures.length === 1 &&
      !this.gauExpenditures[0].gauId &&
      !this.gauExpenditures[0].amount
    ) {
      this.gauExpenditures = [];
    }
    console.log(JSON.stringify(this.gauExpenditures));
    this.loaded = false;
    upsertGauExpenditures({
      expendituresString: JSON.stringify(this.gauExpenditures),
      disbursementId: this.parentId
    })
      .then(result => {
        this.showSuccessToast("Expenditures updates successfully!");
        this.refreshList();
      })
      .catch(error => {
        this.loaded = true;
        this.disbursement = undefined;
        this.showErrorToast(error.body.message);
      });
  }

  validate() {
    let valid = true;
    if (this.gauExpenditures.length > 1) {
      for (const expenditure of this.gauExpenditures) {
        if (!expenditure.amount || !expenditure.gauId) {
          valid = false;
          break;
        }
      }
    }

    return valid;
  }

  showSuccessToast(message) {
    const event = new ShowToastEvent({
      title: "Success!",
      message: message,
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  showErrorToast(message) {
    const event = new ShowToastEvent({
      title: "Oops! Something Went Wrong",
      message: message,
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }
}
