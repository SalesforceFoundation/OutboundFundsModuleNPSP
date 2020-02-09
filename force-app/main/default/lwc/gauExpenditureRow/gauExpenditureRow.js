import { LightningElement, track, api } from "lwc";
import apexSearch from "@salesforce/apex/GauLookupController.search";

export default class GauExpenditureRow extends LightningElement {
  /*****************************************************************************
   * @type object
   * @description immutable object from parent on creation
   */
  @api prefillExpenditure;
  /*****************************************************************************
   * @type number
   * @description total disbursement amount for calculating percentages
   */
  @api parentAmount;
  /*****************************************************************************
   * @type boolean
   * @description disables inputs if parent detects bad conditions
   */
  @api disabled = false;

  /*****************************************************************************
   * @type object
   * @description mutable object used for storing updates. Passed to parent.
   */
  @track gauExpenditure;

  /*****************************************************************************
   * @type number
   * @description  percent is used to calculate expenditure.amount
   */
  @track percent;

  /*****************************************************************************
   * @type array(Object)
   * @description  passed to c-lookup on creation so existing records can show gau name
   */
  prefillSelection = [];

  /*****************************************************************************
   * @description  carry out construction tasks
   * @returnType void
   * @sideEffects gauExpenditure, prefillSelection
   */
  connectedCallback() {
    // move expenditure to mutable structure
    this.gauExpenditure = Object.assign({}, this.prefillExpenditure);

    // populate prefilled lookup
    if (this.gauExpenditure.gauName) {
      this.prefillSelection.push({
        title: this.gauExpenditure.gauName,
        icon: "custom:custom87"
      });
      delete this.gauExpenditure.gauName;
    }

    // disable percent if amount present.
    if (this.gauExpenditure.amount) {
      this.recalculatePercent();
    }

    if (!this.gauExpenditure.gauIsActive) {
      this.disabled = true;
    }
  }
  /*****************************************************************************
   * @description handle event when searchstring is changed. required by c-lookup
   * @returnType void
   * @sideEffects set search results list within c-lookup
   */
  handleSearch(event) {
    // syntax taken from here: https://github.com/pozil/sfdc-ui-lookup-lwc
    const target = event.target;
    apexSearch(event.detail)
      .then(results => {
        target.setSearchResults(results);
      })
      .catch(error => {
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
      });
  }
  /*****************************************************************************
   * @description handle event when gau selection is changed. required by c-lookup
   * @returnType void
   * @sideEffects update guaExpenditure, handleUpdate()
   */
  handleSelectionChange(event) {
    const selection = event.target.getSelection();

    //assign new id, clear current id on cancelation.
    if (selection.length > 0) {
      this.gauExpenditure.gauId = selection[0].id;
    } else {
      this.gauExpenditure.gauId = "";
    }

    // fire event
    this.handleUpdate();
  }
  /*****************************************************************************
   * @description handle event when amount is changed
   * @returnType void
   * @sideEffects gauExpenditure, handleUpdate()
   */
  amountChange(event) {
    // if no change, do nothing
    if (event.target.value === this.gauExpenditure.amount) {
      return;
    }
    this.gauExpenditure.amount = this.enforceValidValue(event);
    this.recalculatePercent();
    this.returnValidity();
    this.handleUpdate();
  }
  /*****************************************************************************
   * @description handle event when percent is changed
   * @returnType void
   * @sideEffects percent, gauExpenditure, handleUpdate()
   */
  percentChange(event) {
    this.percent = this.enforceValidValue(event);
    this.recalculateAmount();
    this.returnValidity();
    this.handleUpdate();
  }
  /*****************************************************************************
   * @description recalculate amount based on percent and parent total
   * @returnType none
   * @sideEffects percent
   */
  recalculateAmount() {
    // parseFloat((...).toFixed(2)) syntax is used to round to .01
    this.gauExpenditure.amount = parseFloat(
      (parseFloat(this.percent / 100) * parseFloat(this.parentAmount)).toFixed(
        2
      )
    );
  }
  /*****************************************************************************
   * @description recalculate percent based on amount and parent total
   * @returnType none
   * @sideEffects percent
   */
  recalculatePercent() {
    // parseFloat((...).toFixed(x)) syntax is used to round
    this.percent = parseFloat(
      (
        (parseFloat(this.gauExpenditure.amount) * 100) /
        parseFloat(this.parentAmount)
      ).toFixed(4)
    );
    if (isNaN(this.percent)) {
      this.percent = 0;
    }
  }
  /*****************************************************************************
   * @description perform common operations to make sure numbers are in valid range
   * @returnType number
   * @sideEffects none
   */
  enforceValidValue(event) {
    // + sign removes trailing zeroes
    // return 0 if undefined/NaN
    return event.target.value ? +Math.abs(event.target.value) : 0;
  }
  /*****************************************************************************
   * @description send updated gau to parent - entire gau is sent for any change.
   * @returnType void
   * @sideEffects event fired
   */
  handleUpdate() {
    this.dispatchEvent(
      new CustomEvent("update", { detail: this.gauExpenditure })
    );
  }
  /*****************************************************************************
   * @description send gau for deletion to parent - entire gau is sent for any change.
   * @returnType void
   * @sideEffects event fired
   */
  handleDelete() {
    this.dispatchEvent(
      new CustomEvent("delete", { detail: this.gauExpenditure })
    );
  }
  /*****************************************************************************
   * @description called from parent for each row, disables save button in parent if invalid.
   * @returnType boolean
   * @sideEffects none
   */
  @api
  returnValidity() {
    return [...this.template.querySelectorAll("lightning-input")].reduce(
      (validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      },
      true
    );
  }
}
