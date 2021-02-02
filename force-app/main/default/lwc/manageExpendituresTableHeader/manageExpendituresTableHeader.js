import { LightningElement } from "lwc";

// TODO: Localize with Custom Labels.
const GENERAL_ACCOUNTING_UNIT_LABEL = "General Accounting Unit";
const AMOUNT_LABEL = "Amount";
const PERCENT_LABEL = "Percent";

export default class ManageExpendituresTableHeader extends LightningElement {
    labels = {
        generalAccountingUnit: GENERAL_ACCOUNTING_UNIT_LABEL,
        amount: AMOUNT_LABEL,
        percent: PERCENT_LABEL,
    };
}
