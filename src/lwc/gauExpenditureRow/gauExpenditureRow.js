import { LightningElement } from "lwc";
import apexSearch from "@salesforce/apex/LookupController.gauSearch";

export default class GauExpenditureRow extends LightningElement {
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
}
