import { LightningElement, api } from "lwc";

export default class ManageExpendituresHeader extends LightningElement {
  @api parentname;
  @api disableSave;
}
