import logging
import random
import string
import warnings

from BaseObjects import BaseOutboundFundsNPSPPage
from cumulusci.robotframework import locator_manager
from robot.libraries.BuiltIn import RobotNotRunningError
from locators_51 import outboundfundsnpsp_lex_locators as locators_51
from cumulusci.robotframework.utils import selenium_retry, capture_screenshot_on_error

locators_by_api_version = {
    51.0: locators_51,  # Spring '21
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
        logging.getLogger("requests.packages.urllib3.connectionpool").setLevel(
            logging.WARN
        )
        locator_manager.register_locators(
            "OutboundFundsNPSP", outboundfundsnpsp_lex_locators
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
        if int(self.latest_api_version) == 51:
            from cumulusci.robotframework import Salesforce

            Salesforce.lex_locators["modal"][
                "button"
            ] = "//div[contains(@class,'uiModal')]//*//button[.='{}']"

    def _check_if_element_exists(self, xpath):
        """Checks if the given xpath exists
        this is only a helper function being called from other keywords
        """
        elements = int(self.selenium.get_element_count(xpath))
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

    def click_link_with_text(self, text):
        """Click on link with passed text"""
        locator = outboundfundsnpsp_lex_locators["link"].format(text)
        self.selenium.wait_until_page_contains_element(locator)
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.driver.execute_script("arguments[0].click()", element)

    def click_save(self):
        """Click Save button in modal's footer"""
        locator = outboundfundsnpsp_lex_locators["new_record"]["footer_button"].format(
            "Save"
        )
        self.selenium.scroll_element_into_view(locator)
        self.salesforce._jsclick(locator)
