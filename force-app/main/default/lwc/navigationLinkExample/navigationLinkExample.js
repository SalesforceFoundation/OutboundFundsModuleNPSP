// navigationLinkExample.js
import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class NavigationLinkExample extends NavigationMixin(
  LightningElement
) {
  @track
  url;

  connectedCallback() {
    // Store the PageReference in a variable to use in handleClick.
    // This is a plain Javascript object that conforms to the
    // PageReference type by including "type" and "attributes" properties.
    // The "state" property is optional.
    this.accountHomePageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Account",
        actionName: "home"
      }
    };
    this[NavigationMixin.GenerateUrl](this.accountHomePageRef).then(
      url => (this.url = url)
    );
  }

  handleClick(evt) {
    // Stop the event's default behavior.
    // Stop the event from bubbling up in the DOM.
    evt.preventDefault();
    evt.stopPropagation();
    // Navigate to the Account Home page.
    this[NavigationMixin.Navigate](this.accountHomePageRef);
  }
}
