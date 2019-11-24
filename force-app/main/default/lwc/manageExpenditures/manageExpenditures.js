import { LightningElement, track, api } from "lwc";

export default class ManageExpenditures extends LightningElement(
  LightningElement
) {
  @api parentId;
  @api parentName;
  @track numbers = [1];

  addRow() {
    this.numbers.push(this.numbers[this.numbers.length - 1] + 1);
  }

  handleDelete(event) {
    if (this.numbers.length > 1) {
      this.numbers.splice(this.numbers.indexOf(event.detail), 1);
    }
  }
}
