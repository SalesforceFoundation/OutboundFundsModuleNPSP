import { LightningElement, track, api } from "lwc";
import apexSearch from "@salesforce/apex/GauLookupController.search";

export default class GauExpenditureRow extends LightningElement {
  @api prefillExpenditure;
  @track gauExpenditure;

  prefillExpenditureString;
  prefillSelection = [];


  connectedCallback() {
    this.gauExpenditure = Object.assign({}, this.prefillExpenditure);
    if(this.gauExpenditure.gauName) {
      this.prefillSelection.push({title: this.gauExpenditure.gauName, icon: 'custom:custom87'});
      delete this.gauExpenditure.gauName;
    }
  }

  handleSearch(event) {
    const target = event.target;
    apexSearch(event.detail)
      .then(results => {
        target.setSearchResults(results);
      })
      .catch(error => {
        this.notifyUser(
          "Lookup Error",
          "An error occured while searching with the lookup field.",
          "error"
        );
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
        this.errors = [error];
      });
  }

  handleSelectionChange(event) {
    const selection = event.target.getSelection();
    if (selection.length > 0) {
      this.gauExpenditure.gauId = selection[0].id;
    } else {
      this.gauExpenditure.gauId = "";
    }
  }

  amountChange(event) {
    this.gauExpenditure.amount = event.target.value;
    this.handleUpdate();
  }

  handleUpdate() {
    this.dispatchEvent(new CustomEvent("update", {detail: this.gauExpenditure}));
  }

  handleDelete() {
    this.dispatchEvent(new CustomEvent("delete", { detail: this.gauExpenditure}));
  }
}
