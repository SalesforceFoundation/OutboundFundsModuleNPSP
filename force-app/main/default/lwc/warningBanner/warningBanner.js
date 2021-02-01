import { LightningElement, api, track } from "lwc";

// TODO: Localize with Custom Labels.
const WARNING_ASSISTIVE_TEXT = "warning";
const WARNING_TITLE = "Description of icon when needed";
const WARNING_ICON_ALTERNATIVE_TEXT = "Warning!";

const INFO_ASSISTIVE_TEXT = "info";
const INFO_TITLE = "Description of icon when needed";
const INFO_ICON_ALTERNATIVE_TEXT = "Information";

const CLOSE_ICON_ALTERNATIVE_TEXT = "close";
export default class WarningBanner extends LightningElement {
    labels = {
        warning: {
            assistiveText: WARNING_ASSISTIVE_TEXT,
            title: WARNING_TITLE,
            icon: {
                alternativeText: WARNING_ICON_ALTERNATIVE_TEXT,
            },
        },
        info: {
            assistiveText: INFO_ASSISTIVE_TEXT,
            title: INFO_TITLE,
            icon: {
                alternativeText: INFO_ICON_ALTERNATIVE_TEXT,
            },
        },
        close: {
            icon: {
                alternativeText: CLOSE_ICON_ALTERNATIVE_TEXT,
            },
        },
    };

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
