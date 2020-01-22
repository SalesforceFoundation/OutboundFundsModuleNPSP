import { LightningElement, api } from "lwc";

export default class TestComposition extends LightningElement {
  @api
  print() {
    return "hello world";
  }
}
