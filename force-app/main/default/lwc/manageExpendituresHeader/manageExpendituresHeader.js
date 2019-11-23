import { LightningElement, api } from 'lwc';

export default class ManageExpendituresHeader extends LightningElement {
  @api parentname;

  handleCancel() {
      this.dispatchEvent(new CustomEvent("cancel"));
  }
}
