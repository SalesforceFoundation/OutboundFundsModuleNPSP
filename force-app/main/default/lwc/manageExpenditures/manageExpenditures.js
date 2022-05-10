import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getDisbursement from "@salesforce/apex/GauExpendituresManager.getDisbursement";
import upsertGauExpenditures from "@salesforce/apex/GauExpendituresManager.upsertGauExpenditures";

const STATUS_PAID = "Paid";
const STATUS_CANCELED = "Cancelled";

const REMAINING_AMOUNT_STATUS_VALID = "VALID";
const REMAINING_AMOUNT_STATUS_INVALID = "INVALID";

// TODO: Use Custom Labels for localization.
const MISSING_GAU_IDS_ERROR = "Please remove any incomplete rows, then try again.";
const EXPENDITURES_UPDATED_SUCCESS_MESSAGE = "Expenditures updated successfully!";

const SUCCESS_TOAST_TITLE = "Success!";
const SUCCESS_TOAST_VARIANT = "success";

const ERROR_TOAST_TITLE = "Oops! Something Went Wrong";
const ERROR_TOAST_VARIANT = "error";
const ERROR_TOAST_MODE = "dismissable";

const IS_NOT_DISBURSEMENT_WARNING_BANNER_MESSAGE =
    "This component is meant for use on a Disbursement lightning page. Questions? Visit the Power Of Us Hub.";
const IS_DISBURSEMENT_WARNING_BANNER_MESSAGE =
    "Click 'Refresh List' to start with the latest data.";
const ELIGIBLE_STATUS_WARNING_BANNER_MESSAGE =
    "Disbursements with a status of 'Paid' or 'Cancelled' are not eligible for update here";
const NON_ZERO_AMOUNT_WARNING_BANNER_MESSAGE =
    "Please give this Disbursement an amount before managing the expenditures.";
const GENERAL_ACCOUNTING_UNIT = "General Accounting Unit";
const TOTAL_AMOUNT_REMAINING = "Total Amount Remaining:";
const ADD_ROW_LABEL = "Add Row";
const REFRESH_LABEL = "Refresh List";
const SAVE_UPDATES_LABEL = "Save Updates";
const LOADING_ALTERNATIVE_TEXT = "Loading";

export default class ManageExpenditures extends LightningElement {
    labels = {
        isNotDisbursement: {
            warningBanner: {
                message: IS_NOT_DISBURSEMENT_WARNING_BANNER_MESSAGE,
            },
        },
        isDisbursement: {
            warningBanner: {
                message: IS_DISBURSEMENT_WARNING_BANNER_MESSAGE,
            },
        },
        eligibleStatus: {
            warningBanner: {
                message: ELIGIBLE_STATUS_WARNING_BANNER_MESSAGE,
            },
        },
        nonZeroAmount: {
            warningBanner: {
                message: NON_ZERO_AMOUNT_WARNING_BANNER_MESSAGE,
            },
        },
        generalAccountingUnit: GENERAL_ACCOUNTING_UNIT,
        totalAmountRemaining: TOTAL_AMOUNT_REMAINING,
        buttons: {
            addRow: ADD_ROW_LABEL,
            refreshList: REFRESH_LABEL,
            saveUpdates: SAVE_UPDATES_LABEL,
        },
        loading: {
            alternativeText: LOADING_ALTERNATIVE_TEXT,
        },
    };

    /*****************************************************************************
     * @type String
     * @description Received from lightning page. Name of object.
     */
    @api objectApiName;

    /*****************************************************************************
     * @type String
     * @description Received from lightning page. Id of Disbursement.
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
     * Dictates whether to show the warning about a Disbursement with an ineligible status.
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
     * @sideEffects isDisbursement, refreshList()
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
     * pad(), updateRemainingExpenditures()
     */
    refreshList() {
        // set spinner to empty
        this.loaded = false;
        // once display is removed, empty expenditures list
        this.gauExpenditures = [];
        getDisbursement({ disbursementId: this.recordId })
            .then((result) => {
                // set gauExpenditures and total amount
                this.parentAmount = result.amount;
                this.nonZeroAmount = result.amount > 0;
                this.gauExpenditures = result.expenditures;
                // add empty row if gauExpenditures is empty
                this.pad(0);
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
        if (
            (result.status === STATUS_PAID && !this.listIsEmpty(this.gauExpenditures)) ||
            result.status === STATUS_CANCELED
        ) {
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
     * @sideEffects gauExpenditures, pad(), updateRemainingAmount()
     */
    handleUpdate(event) {
        // get index from rowId of expenditure passed from child
        let index = this.gauExpenditures
            .map((expenditure) => {
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
                this.pad(1);
                this.gauExpenditures.splice(index, 1);
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
    pad(length) {
        if (this.gauExpenditures.length === length) {
            this.addRow();
        }
    }

    /*****************************************************************************
     * @description  After update, take validated amounts and update running total
     * @returnType void
     * @sideEffects disableSave, remainingAmount, remainingAmountStatus, validateRows()
     */
    updateRemainingAmount() {
        // if there are active errors from lightning-inputs, then disable save and return early.
        let validRows = this.validateRows();
        this.disableSave = !validRows;
        if (this.disableSave) {
            return;
        }

        // tally up total dedicated to the expenditures
        let usedAmount = this.gauExpenditures.reduce(function (total, eachExpenditure) {
            if (eachExpenditure.amount) {
                return parseFloat(total) + parseFloat(eachExpenditure.amount);
            }
            return parseFloat(total);
        }, 0);
        // parseFloat((...).toFixed(x)) syntax is used to round as needed
        // using 6 places instead of 4 to conform with formatted-number specification
        usedAmount = parseFloat(usedAmount.toFixed(6));
        this.remainingPercentage = parseFloat(
            ((this.parentAmount - usedAmount) / this.parentAmount).toFixed(6)
        );
        usedAmount = parseFloat(usedAmount.toFixed(2));
        this.remainingAmount = parseFloat((this.parentAmount - usedAmount).toFixed(2));
        // set css based on total used
        if (this.remainingAmount >= 0) {
            this.remainingAmountStatus = REMAINING_AMOUNT_STATUS_VALID;
            this.disableSave = false;
        } else {
            this.remainingAmountStatus = REMAINING_AMOUNT_STATUS_INVALID;
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
            this.showErrorToast(MISSING_GAU_IDS_ERROR);
            return;
        }
        // if there is only an empty row in the list, remove it.
        if (this.listIsEmpty(this.gauExpenditures)) {
            this.gauExpenditures = [];
        }
        // turn on spinner
        this.loaded = false;
        // send list to server
        upsertGauExpenditures({
            expendituresString: JSON.stringify(this.gauExpenditures),
            disbursementId: this.recordId,
        })
            .then(() => {
                this.showSuccessToast(EXPENDITURES_UPDATED_SUCCESS_MESSAGE);
                this.refreshList();
            })
            .catch((error) => {
                this.loaded = true;
                this.showErrorToast(error.body.message);
            });
    }
    listIsEmpty(gauExpenditures) {
        return (
            gauExpenditures.length === 1 &&
            !gauExpenditures[0].gauId &&
            !gauExpenditures[0].amount
        );
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
     * @description Invoke success toast event
     * @returnType void
     * @sideEffects dispatch toast event
     */
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: message,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }

    /*****************************************************************************
     * @description Invoke error toast event
     * @returnType void
     * @sideEffects dispatch toast event
     */
    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: message,
            variant: ERROR_TOAST_VARIANT,
            mode: ERROR_TOAST_MODE,
        });
        this.dispatchEvent(event);
    }
}
