import { createElement } from "lwc";
import WarningBanner from "c/warningBanner";

describe("warning banner", () => {
    let component;
    const message = "message";

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

    describe("info", () => {
        beforeEach(() => {
            component.variant = "info-dismissable";
            document.body.appendChild(component);
        });

        it("should be accessible", async () => {
            return Promise.resolve(() => {
                return expect(component).toBeAccessible();
            });
        });
    });

    describe("warning", () => {
        beforeEach(() => {
            document.body.appendChild(component);
        });

        it("should be accessible", () => {
            return Promise.resolve(() => {
                return expect(component).toBeAccessible();
            });
        });
    });
});
