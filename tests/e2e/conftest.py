import os
import time

import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options


@pytest.fixture(scope="session")
def base_url():
    """ Site under test; set E2E_BASE_URL to point at the target. """
    return os.environ.get("E2E_BASE_URL", "http://localhost:5000").rstrip("/")


def _chrome_options():
    """ Headless Chrome options that work in a container. """
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1280,1024")
    return options


def _remote_driver(remote_url, attempts=10, delay=3):
    """ Connect to a remote Selenium, retrying while the grid comes up. """
    last_error = None
    for _ in range(attempts):
        try:
            return webdriver.Remote(command_executor=remote_url,
                                    options=_chrome_options())
        except Exception as error:
            last_error = error
            time.sleep(delay)
    raise last_error


@pytest.fixture
def driver():
    """ Remote Chrome when SELENIUM_REMOTE_URL is set, else a local one. """
    remote_url = os.environ.get("SELENIUM_REMOTE_URL")
    if remote_url:
        driver = _remote_driver(remote_url)
    else:
        driver = webdriver.Chrome(options=_chrome_options())

    driver.set_page_load_timeout(30)
    yield driver
    driver.quit()
