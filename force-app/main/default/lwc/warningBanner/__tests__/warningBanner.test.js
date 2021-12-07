import { createElement } from "lwc";
import WarningBanner, {
    WARNING_ASSISTIVE_TEXT,
    WARNING_TITLE,
    WARNING_ICON_ALTERNATIVE_TEXT,
    INFO_ASSISTIVE_TEXT,
    INFO_TITLE,
    INFO_ICON_ALTERNATIVE_TEXT,
    CLOSE_ICON_ALTERNATIVE_TEXT,
} from "c/warningBanner";

describe.each([
    ["with message", `random number: ${Math.random()}`, "should display message"],
    ["without message", null, "should not display message"],
])("warning-banner %s", (_, message, shouldDisplayMessageTitle) => {
    let component;

    beforeEach(() => {
        component = createElement("c-warning-banner", {
            is: WarningBanner,
        });
        component.message = message;
    });

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        component = undefined;
    });

    describe("info variant", () => {
        beforeEach(() => {
            component.variant = "info-dismissable";
            document.body.appendChild(component);

            // Return one Promise.resolve so <template> tags are re-rendered.
            return Promise.resolve();
        });

        it("should be accessible", async () => {
            await expect(component).toBeAccessible();
        });

        it("should display info alert", () => {
            // component has one child.
            expect(component.shadowRoot.childNodes.length).toEqual(1);

            const alerts = component.shadowRoot.querySelectorAll(
                `div.slds-notify.slds-theme_info[role="alert"]`
            );
            expect(alerts).not.toBeNull();
            expect(alerts.length).toEqual(1);

            // The info alert is the first child.
            expect(alerts[0]).toEqual(component.shadowRoot.childNodes[0]);
        });

        it("should display info assistive text", () => {
            const assistiveTexts = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_info span.slds-assistive-text"
            );
            expect(assistiveTexts).not.toBeNull();
            expect(assistiveTexts.length).toEqual(1);
            expect(assistiveTexts[0].textContent).toEqual(INFO_ASSISTIVE_TEXT);
        });

        it("should display info icon", () => {
            const iconContainers = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_info span.slds-icon_container.slds-m-right_x-small.slds-icon-utility-user"
            );
            expect(iconContainers).not.toBeNull();
            expect(iconContainers.length).toEqual(1);
            expect(iconContainers[0].title).toEqual(INFO_TITLE);

            const icons = iconContainers[0].querySelectorAll("lightning-icon");
            expect(icons).not.toBeNull();
            expect(icons.length).toEqual(1);

            const icon = icons[0];
            expect(icon.iconName).toEqual("utility:announcement");
            expect(icon.alternativeText).toEqual(INFO_ICON_ALTERNATIVE_TEXT);
            expect(icon.variant).toEqual("inverse");
            expect(icon.size).toEqual("x-small");
        });

        it("shouldDisplayMessageTitle", () => {
            const messages = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_info h2"
            );
            expect(messages).not.toBeNull();
            expect(messages.length).toEqual(1);
            expect(messages[0].textContent).toEqual(message);
        });

        it("should display close icon", () => {
            const closeIcons = component.shadowRoot.querySelectorAll(
                `div.slds-notify.slds-theme_info > lightning-icon.slds-notify__close`
            );
            expect(closeIcons).not.toBeNull();
            expect(closeIcons.length).toEqual(1);

            const closeIcon = closeIcons[0];
            expect(closeIcon.iconName).toEqual("utility:close");
            expect(closeIcon.alternativeText).toEqual(CLOSE_ICON_ALTERNATIVE_TEXT);
            expect(closeIcon.variant).toEqual("inverse");
            expect(closeIcon.size).toEqual("x-small");
        });

        it("clicking close icon hides info alert", () => {
            const closeIcons = component.shadowRoot.querySelectorAll(
                `div.slds-notify.slds-theme_info > lightning-icon.slds-notify__close`
            );
            expect(closeIcons).not.toBeNull();
            expect(closeIcons.length).toEqual(1);

            const closeIcon = closeIcons[0];
            closeIcon.click();

            // Clicking close un-renders info alert.
            return Promise.resolve().then(() => {
                expect(component.shadowRoot.childNodes.length).toEqual(0);

                // Component should still be accessible after closing.
                return expect(component).toBeAccessible();
            });
        });
    });

    describe.each([
        [`not "info-dismissable"`, `anything that is not exactly "info-dismissable"`],
        ["null", null],
    ])("default variant as warning: variant %s", (__, variant) => {
        beforeEach(() => {
            component.variant = variant;
            document.body.appendChild(component);

            // Return one Promise.resolve so <template> tags are re-rendered.
            return Promise.resolve();
        });

        it("should be accessible", async () => {
            await expect(component).toBeAccessible();
        });

        it("should display warning alert", () => {
            // component has one child.
            expect(component.shadowRoot.childNodes.length).toEqual(1);

            const alerts = component.shadowRoot.querySelectorAll(
                `div.slds-notify.slds-theme_warning[role="alert"]`
            );
            expect(alerts).not.toBeNull();
            expect(alerts.length).toEqual(1);

            // The info alert is the first child.
            expect(alerts[0]).toEqual(component.shadowRoot.childNodes[0]);
        });

        it("should display info assistive text", () => {
            const assistiveTexts = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_warning span.slds-assistive-text"
            );
            expect(assistiveTexts).not.toBeNull();
            expect(assistiveTexts.length).toEqual(1);
            expect(assistiveTexts[0].textContent).toEqual(WARNING_ASSISTIVE_TEXT);
        });

        it("should display warning icon", () => {
            const iconContainers = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_warning span.slds-icon_container.slds-m-right_x-small.slds-icon-utility-warning"
            );
            expect(iconContainers).not.toBeNull();
            expect(iconContainers.length).toEqual(1);
            expect(iconContainers[0].title).toEqual(WARNING_TITLE);

            const icons = iconContainers[0].querySelectorAll("lightning-icon");
            expect(icons).not.toBeNull();
            expect(icons.length).toEqual(1);

            const icon = icons[0];
            expect(icon.iconName).toEqual("utility:warning");
            expect(icon.alternativeText).toEqual(WARNING_ICON_ALTERNATIVE_TEXT);
            expect(icon.variant).toEqual("warning");
            expect(icon.size).toEqual("x-small");
        });

        it("shouldDisplayMessageTitle", () => {
            const messages = component.shadowRoot.querySelectorAll(
                "div.slds-notify.slds-theme_warning h2"
            );
            expect(messages).not.toBeNull();
            expect(messages.length).toEqual(1);
            expect(messages[0].textContent).toEqual(message);
        });

        it("should not display close icon", () => {
            const closeIcons = component.shadowRoot.querySelectorAll(
                `div.slds-notify.slds-theme_warning > lightning-icon.slds-notify__close`
            );
            expect(closeIcons).not.toBeNull();
            expect(closeIcons.length).toEqual(0);
        });
    });
});
