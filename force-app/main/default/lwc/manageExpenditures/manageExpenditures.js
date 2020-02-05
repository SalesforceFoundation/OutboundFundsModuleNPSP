import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";
import upsertGauExpenditures from "@salesforce/apex/GauExpendituresManager.upsertGauExpenditures";
export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  /*****************************************************************************
   * @type String
   * @description Recieved from lightning page. Name of object.
   */
  @api objectApiName;
  /*****************************************************************************
   * @type String
   * @description Recieved from lightning page. Id of Disbursement.
   */
  @api recordId;
  /*****************************************************************************
   * @type Number
   * @description Queried based on recordId. Amount associated w/ disbursement.
   */
  @track parentAmount;
  /*****************************************************************************
   * @type Array(Object)
   * @description List of expenditures - passed to c-gau-expenditure-row components.
   */
  @track gauExpenditures;
  /*****************************************************************************
   * @type Number
   * @description calculated on expenditure update. displayed at bottom of table.
   */
  @track remainingAmount;
  /*****************************************************************************
   * @type Number
   * @description calculated on expenditure update. displayed at bottom of table.
   */
  @track remainingPercentage;
  /*****************************************************************************
   * @type String
   * @description calculated on expenditure update. String value corresponds to
   * the name of the *css selector* which is applied to the remainingAmount element
   */
  @track remainingAmountStatus;
  /*****************************************************************************
   * @type Boolean
   * @description calculated on expenditure update.
   * populates the 'disabled' attribute on the save button.
   */
  @track disableSave;
  /*****************************************************************************
   * @type Boolean
   * @description set on load to ensure component is only on Disbursement Layout. Error message displayed otherwise.
   */
  @track isDisbursement = false;
  /*****************************************************************************
   * @type Boolean
   * @description calculated on expenditure update.
   * populates the 'disabled' attribute on the save button.
   */
  @track loaded = false;
  /*****************************************************************************
   * @type Boolean
   * @description calculated on expenditure update.
   * Dictates whether to show the warning about a Disbursement with no amount.
   */
  @track nonZeroAmount = false;
  /*****************************************************************************
   * @type Boolean
   * @description calculated on component creation
   * Dictates whether to show the warning about a Disbursement with an ineligble status.
   */
  @track eligibleStatus = false;
  /*****************************************************************************
   * @type Boolean
   * @description calculated on component creation
   * Passed to table rows to disable when needed
   */
  @track disableRows = false;

  /*****************************************************************************
   * @description  carry out construction tasks
   * @returnType void
   * @sideEffects isDusbursement, refreshList()
   */
  connectedCallback() {
    // set error only needed on load for wrong object
    this.isDisbursement = this.objectApiName === "outfunds__Disbursement__c";
    // make initial server call
    this.refreshList();
  }

  /*****************************************************************************
   * @description  retrieve disbursement and expenditures from server, process as needed
   * @returnType void
   * @sideEffects loaded, gauExpenditures, parentAmount, nonZeroAmount, gauExpenditures, loaded,
   * padEmpty(), updateRemainingExpenditures()
   */
  refreshList() {
    // set spinner to empty
    this.loaded = false;
    // once display is removed, empty expenditures list
    this.gauExpenditures = [];
    getDisbursement({ disbursementId: this.recordId })
      .then(result => {
        // set gauExpenditures and total amount
        this.parentAmount = result.amount;
        this.nonZeroAmount = result.amount > 0;
        this.gauExpenditures = result.expenditures;
        // add empty row if gauExpenditures is empty
        this.padEmpty();
        // update remaining amount and needed css values.
        this.updateRemainingAmount();
        // check disbursement status for update eligibility
        this.validateStatus(result);

        this.disableRows = !this.eligibleStatus;
        this.loaded = true;
      })
      .catch(() => {
        this.loaded = true;
      });
  }
  /*****************************************************************************
   * @description  check to see if Disbursement status allows for updates
   * @returnType void
   * @sideEffects eligibleStatus, disableSave
   */
  validateStatus(result) {
    if (result.status === "Paid" || result.status === "Cancelled") {
      this.disableSave = true;
      this.eligibleStatus = false;
    } else {
      this.eligibleStatus = true;
    }
  }

  /*****************************************************************************
   * @description  add row to table, incl. adding first row when array is empty
   * @returnType void
   * @sideEffects gauExpenditures
   */
  addRow() {
    // increment rowId if there are existing rows, otherwise use 1
    let rowId =
      this.gauExpenditures.length > 0
        ? this.gauExpenditures[this.gauExpenditures.length - 1].rowId + 1
        : 1;
    // row starts with only rowId - can't save until user deletes or populates.
    this.gauExpenditures.push({ rowId: rowId });
  }

  /*****************************************************************************
   * @description  handle events from children - update and delete.
   * @returnType void
   * @sideEffects gauExpenditures, padEmpty(), updateRemainingAmount()
   */
  handleUpdate(event) {
    // get index from rowId of expenditure passed from child
    let index = this.gauExpenditures
      .map(expenditure => {
        return expenditure.rowId;
      })
      .indexOf(event.detail.rowId);
    switch (event.type) {
      case "update":
        // replace gauExpenditure
        this.gauExpenditures[index] = event.detail;
        break;
      case "delete":
        // delete and add row if it was the last row
        this.gauExpenditures.splice(index, 1);
        this.padEmpty();
        break;
      default:
        break;
    }
    // reset remaining total and css values
    this.updateRemainingAmount();
  }
  /*****************************************************************************
   * @description  wrap some logic to create an empty row when gauExpenditures is in a position when it might become empty.
   * @returnType void
   * @sideEffects gauExpenditures, addRow()
   */
  padEmpty() {
    if (this.gauExpenditures.length === 0) {
      this.addRow();
    }
  }

  /*****************************************************************************
   * @description  After update, take validated amounts and update running total
   * @returnType void
   * @sideEffects disableSave, remainingAmount, remainingAmounStatus, validateRows()
   */
  updateRemainingAmount() {
    // if there are active errors from lightning-inputs, then disable save and return early.
    let validRows = this.validateRows();
    this.disableSave = !validRows;
    if (this.disableSave) {
      return;
    }

    // tally up total dedicated to the expenditures
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
    // parseFloat((...).toFixed(x)) syntax is used to round as needed
    // using 6 places instead of 4 to conform with formatted-number specification
    usedAmount = parseFloat(usedAmount.toFixed(6));
    this.remainingPercentage = parseFloat(
      ((this.parentAmount - usedAmount) / this.parentAmount).toFixed(6)
    );
    usedAmount = parseFloat(usedAmount.toFixed(2));
    this.remainingAmount = parseFloat(
      (this.parentAmount - usedAmount).toFixed(2)
    );
    // set css based on total used
    if (this.remainingAmount >= 0) {
      this.remainingAmountStatus = "VALID";
      this.disableSave = false;
    } else {
      this.remainingAmountStatus = "INVALID";
      this.disableSave = true;
    }
  }
  /*****************************************************************************
   * @description  get reportValidity() from each of the children
   * @returnType boolean
   * @sideEffects none
   */
  validateRows() {
    return [...this.template.querySelectorAll("c-gau-expenditure-row")].reduce(
      (validSoFar, childComponent) => {
        return validSoFar && childComponent.returnValidity();
      },
      true
    );
  }
  /*****************************************************************************
   * @description  call validation and send updated list to server
   * @returnType void
   * @sideEffects gauExpenditures, loaded, validate(), showErrorToast(),
   * upsertGauExpenditures(), showSuccessToast(), refreshList()
   */
  handleSave() {
    // if there are missing gauIds or amounts, return early
    if (!this.validate()) {
      this.showErrorToast("Please remove any incomplete rows, then try again.");
      return;
    }
    // if there is only an empty row in the list, remove it.
    if (
      this.gauExpenditures.length === 1 &&
      !this.gauExpenditures[0].gauId &&
      !this.gauExpenditures[0].amount
    ) {
      this.gauExpenditures = [];
    }
    // turn on spinner
    this.loaded = false;
    // send list to server
    upsertGauExpenditures({
      expendituresString: JSON.stringify(this.gauExpenditures),
      disbursementId: this.recordId
    })
      .then(() => {
        this.showSuccessToast("Expenditures updated successfully!");
        this.refreshList();
      })
      .catch(error => {
        this.loaded = true;
        this.showErrorToast(error.body.message);
      });
  }
  /*****************************************************************************
   * @description  ensure each row has a gauId and an amount
   * @returnType Boolean
   * @sideEffects none
   */
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
  /*****************************************************************************
   * @description envoke success toast event
   * @returnType void
   * @sideEffects dispatch toast event
   */
  showSuccessToast(message) {
    const event = new ShowToastEvent({
      title: "Success!",
      message: message,
      variant: "success"
    });
    this.dispatchEvent(event);
  }
  /*****************************************************************************
   * @description envoke error toast event
   * @returnType void
   * @sideEffects dispatch toast event
   */
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
