import { LightningElement, track } from "lwc";
import apexSearch from "@salesforce/apex/GauLookupController.search";

export default class GauExpenditureRow extends LightningElement {
  @track gauId = "";
  @track amount = "";

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
      this.gauId = selection[0].id;
    } else {
      this.gauId = "";
    }
  }

  amountChange(event) {
    this.amount = event.target.value;
  }
}
