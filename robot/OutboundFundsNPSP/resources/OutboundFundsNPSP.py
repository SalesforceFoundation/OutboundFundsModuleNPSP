import logging
import random
import string
import warnings
import time

from BaseObjects import BaseOutboundFundsNPSPPage
from robot.libraries.BuiltIn import RobotNotRunningError
from locators_54 import outboundfundsnpsp_lex_locators as locators_54
from locators_51 import outboundfundsnpsp_lex_locators as locators_51
from cumulusci.robotframework.utils import selenium_retry, capture_screenshot_on_error

locators_by_api_version = {
    51.0: locators_51,  # Spring '21
    54.0: locators_54,  
}
# will get populated in _init_locators
outboundfundsnpsp_lex_locators = {}


@selenium_retry
class OutboundFundsNPSP(BaseOutboundFundsNPSPPage):
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_VERSION = 1.0

    def __init__(self, debug=False):
        self.debug = debug
        self.current_page = None
        self._session_records = []
        # Turn off info logging of all http requests
        logging.getLogger("requests.packages.urllib3.connectionpool").setLevel(
            logging.WARN
        )
        self._init_locators()

    def _init_locators(self):
        try:
            client = self.cumulusci.tooling
            response = client._call_salesforce(
                "GET", "https://{}/services/data".format(client.sf_instance)
            )
            self.latest_api_version = float(response.json()[-1]["version"])
            if self.latest_api_version not in locators_by_api_version:
                warnings.warn(
                    "Could not find locator library for API %d"
                    % self.latest_api_version
                )
                self.latest_api_version = max(locators_by_api_version.keys())
        except RobotNotRunningError:
            # We aren't part of a running test, likely because we are
            # generating keyword documentation. If that's the case, assume
            # the latest supported version
            self.latest_api_version = max(locators_by_api_version.keys())
        locators = locators_by_api_version[self.latest_api_version]
        outboundfundsnpsp_lex_locators.update(locators)

    def get_outboundfundsnpsp_lex_locators(self, path, *args, **kwargs):
        """ Returns a rendered locator string from the outboundfundsnpsp_lex_locators
            dictionary.  This can be useful if you want to use an element in
            a different way than the built in keywords allow.
        """
        locator = outboundfundsnpsp_lex_locators
        for key in path.split("."):
            locator = locator[key]
        main_loc = locator.format(*args, **kwargs)
        return main_loc

    def get_namespace_prefix(self, name):
        parts = name.split("__")
        if parts[-1] == "c":
            parts = parts[:-1]
        if len(parts) > 1:
            return parts[0] + "__"
        else:
            return ""

    def get_outfundsnpsp_namespace_prefix(self):
        if not hasattr(self.cumulusci, "_describe_result"):
            self.cumulusci._describe_result = self.cumulusci.sf.describe()
        objects = self.cumulusci._describe_result["sobjects"]
        fundingprogram_object = [o for o in objects if o["label"] == "Funding Program"][
            0
        ]
        return self.get_namespace_prefix(fundingprogram_object["name"])

    def get_outfundsnpspext_namespace_prefix(self):
        if not hasattr(self.cumulusci, "_describe_result"):
            self.cumulusci._describe_result = self.cumulusci.sf.describe()
        objects = self.cumulusci._describe_result["sobjects"]
        gauexp_object = [o for o in objects if o["label"] == "GAU Expenditure"][0]
        return self.get_namespace_prefix(gauexp_object["name"])

    def get_npsp_namespace_prefix(self):
        if not hasattr(self.cumulusci, "_describe_result"):
            self.cumulusci._describe_result = self.cumulusci.sf.describe()
        objects = self.cumulusci._describe_result["sobjects"]
        gau_object = [o for o in objects if o["label"] == "General Accounting Unit"][0]
        return self.get_namespace_prefix(gau_object["name"])

    def get_outboundfundsnpsp_locator(self, path, *args, **kwargs):
        """ Returns a rendered locator string from the npsp_lex_locators
            dictionary.  This can be useful if you want to use an element in
            a different way than the built in keywords allow.
        """
        locator = outboundfundsnpsp_lex_locators
        for key in path.split("."):
            locator = locator[key]
        main_loc = locator.format(*args, **kwargs)
        return main_loc

    def _check_if_element_exists(self, xpath):
        """Checks if the given xpath exists
        this is only a helper function being called from other keywords
        """
        elements = int(self.selenium.get_element_count(xpath))
        return True if elements > 0 else False

    def check_if_element_exists(self, xpath):
        """Checks if an element with given xpath exists"""
        elements = self.selenium.get_element_count(xpath)
        return True if elements > 0 else False

    def new_random_string(self, len=5):
        """Generate a random string of fixed length """
        return "".join(random.choice(string.ascii_lowercase) for _ in range(len))

    def generate_new_string(self, prefix="Robot Test"):
        """Generates a random string with Robot Test added as prefix"""
        return "{PREFIX} {RANDOM}".format(
            PREFIX=prefix, RANDOM=self.new_random_string(len=5)
        )

    def random_email(self, prefix="robot_", suffix="example.com"):
        """
        Return a random fake email address.
        :param prefix: Some text to put in front of the randomized part of the username.
                   Defaults to "robot_"
        :type  prefix: str
        :param suffix: The domain part of the email address.
                   Defaults to "example.com"
        :type  suffix: str
        :returns: The fake email address.
        :rtype: str
        """
        return "{PREFIX}{RANDOM}@{SUFFIX}".format(
            PREFIX=prefix, RANDOM=self.new_random_string(len=5), SUFFIX=suffix
        )

    @capture_screenshot_on_error
    def click_link_with_text(self, text):
        """Click on link with passed text"""
        locator = outboundfundsnpsp_lex_locators["link"].format(text)
        self.selenium.wait_until_page_contains_element(locator)
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.driver.execute_script("arguments[0].click()", element)

    @capture_screenshot_on_error
    def click_save(self):
        """Click Save button in modal's footer"""
        locator = outboundfundsnpsp_lex_locators["new_record"]["footer_button"].format(
            "Save"
        )
        self.selenium.scroll_element_into_view(locator)
        self.salesforce._jsclick(locator)
        self.salesforce.wait_until_loading_is_complete()

    @capture_screenshot_on_error
    def validate_field_value(self, field, status, value, section=None):
        """If status is 'contains' then the specified value should be present in the field
        'does not contain' then the specified value should not be present in the field
        """
        if section is not None:
            section = "text:" + section
            self.selenium.scroll_element_into_view(section)
        list_found = False
        locators = outboundfundsnpsp_lex_locators["confirm"].values()
        if status == "contains":
            for i in locators:
                print("inside for loop")
                locator = i.format(field, value)
                print(locator)
                if self.check_if_element_exists(locator):
                    print(f"element exists {locator}")
                    actual_value = self.selenium.get_webelement(locator).text
                    print(f"actual value is {actual_value}")
                    assert (
                        value == actual_value
                    ), "Expected {} value to be {} but found {}".format(
                        field, value, actual_value
                    )
                    list_found = True
                    break
        if status == "does not contain":
            for i in locators:
                locator = i.format(field, value)
                if self.check_if_element_exists(locator):
                    print(f"locator is {locator}")
                    raise Exception(f"{field} should not contain value {value}")
            list_found = True

        assert list_found, "locator not found"

    @capture_screenshot_on_error
    def click_tab(self, label):
        """Click on a tab on a record page"""
        locator = outboundfundsnpsp_lex_locators["tab"]["tab_header"].format(label)
        self.selenium.wait_until_element_is_enabled(
            locator, error="Tab button is not available"
        )
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.driver.execute_script("arguments[0].click()", element)

    def click_related_list_link_with_text(self, text):
        """Click on link with passed text in a related list table"""
        locator = outboundfundsnpsp_lex_locators["related"]["flexi_link"].format(text)
        self.selenium.wait_until_page_contains_element(locator)
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.driver.execute_script("arguments[0].click()", element)

    def click_related_list_wrapper_button(self, heading, button_title):
        """ loads the related list  and clicks on the button on the list """
        locator = outboundfundsnpsp_lex_locators["related"]["flexi_button"].format(
            heading, button_title
        )
        self.salesforce._jsclick(locator)
        self.salesforce.wait_until_loading_is_complete()

    @capture_screenshot_on_error
    def save_disbursement(self):
        """Click Save Disbursement"""
        locator = outboundfundsnpsp_lex_locators["details"]["button"].format("Save")
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def verify_row_count(self, value):
        """verifies if actual row count matches with expected value"""
        locator = outboundfundsnpsp_lex_locators["related"]["count"]
        actual_value = self.selenium.get_webelements(locator)
        count = len(actual_value)
        assert int(value) == count, "Expected value to be {} but found {}".format(
            value, count
        )

    @capture_screenshot_on_error
    def select_tab(self, title):
        """ Switch between different tabs on a record page like Related, Details, News, Activity and Chatter
            Pass title of the tab
        """
        tab_found = False
        locators = outboundfundsnpsp_lex_locators["tabs"].values()
        for i in locators:
            locator = i.format(title)
            if self.check_if_element_exists(locator):
                print(locator)
                buttons = self.selenium.get_webelements(locator)
                for button in buttons:
                    print(button)
                    if button.is_displayed():
                        print("button displayed is {}".format(button))
                        self.salesforce._focus(button)
                        button.click()
                        time.sleep(5)
                        tab_found = True
                        break

        assert tab_found, "tab not found"

    @capture_screenshot_on_error
    def select_value_from_picklist(self, dropdown, value):
        """Select given value in the dropdown field"""
        locator = outboundfundsnpsp_lex_locators["new_record"]["dropdown_field"].format(
            dropdown
        )
        self.selenium.get_webelement(locator).click()
        popup_loc = outboundfundsnpsp_lex_locators["new_record"]["dropdown_popup"]
        self.selenium.wait_until_page_contains_element(
            popup_loc, error="Picklist dropdown did not open"
        )
        value_loc = outboundfundsnpsp_lex_locators["new_record"][
            "dropdown_value"
        ].format(value)
        self.salesforce._jsclick(value_loc)

    @capture_screenshot_on_error
    def add_date(self, title, date):
        """ Clicks on the 'Date' field in Form and picks a date in the argument """
        locator = outboundfundsnpsp_lex_locators["new_record"]["date_field"].format(
            title
        )
        self.selenium.set_focus_to_element(locator)
        self.selenium.clear_element_text(locator)
        self.selenium.get_webelement(locator).send_keys(date)

    @capture_screenshot_on_error
    def page_should_not_contain_locator(self, path, *args, **kwargs):
        """Waits for the locator specified to be not present on the page"""
        main_loc = self.get_outboundfundsnpsp_lex_locators(path, *args, **kwargs)
        self.selenium.wait_until_page_does_not_contain_element(main_loc, timeout=60)

    def verify_button_status(self, **kwargs):
        """ Verify the button is disabled/enabled, pass the name of the buttin
        and the expected status of the buttin as either enabled or disabled"""

        for key, value in kwargs.items():
            locator = outboundfundsnpsp_lex_locators["button-with-text"].format(key)
            self.selenium.wait_until_element_is_visible(
                locator, error=f"'{key}' is not displayed on the page"
            )
            if value == "disabled":
                actual_value = self.selenium.get_webelement(locator).get_attribute(
                    value
                )
                if actual_value is None or actual_value is False:
                    raise Exception(
                        f"Expected {key} status to be {value} but found {actual_value}"
                    )
            elif value == "enabled":
                actual_value = self.selenium.get_webelement(locator).get_attribute(
                    "disabled"
                )
                if not (actual_value is None or actual_value is False):
                    raise Exception(
                        f"Expected {key} status to be {value} but found {actual_value}"
                    )

    def populate_field_with_id(self, id, value):
        """Populate field with id on manage expenditure page"""
        locator = outboundfundsnpsp_lex_locators["id"].format(id)
        if value == "null":
            field = self.selenium.get_webelement(locator)
            self.salesforce._clear(field)
        else:
            self.salesforce._populate_field(locator, value)
