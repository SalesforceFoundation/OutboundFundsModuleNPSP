import { LightningElement, api, track } from "lwc";

export default class WarningBanner extends LightningElement {
    @api message;
    @api variant;
    @track warning = false;
    @track info = false;
    connectedCallback() {
        switch (this.variant) {
            case "info-dismissable":
                this.info = true;
                break;
            default:
                this.warning = true;
                break;
        }
    }

    handleClose() {
        this.info = false;
    }
}
