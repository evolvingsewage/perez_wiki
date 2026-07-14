import pytest
from selenium.webdriver.common.by import By

# English pages and their German counterparts
EN_PAGES = ["/", "/resume", "/projects", "/about", "/contact"]
DE_PAGES = ["/de", "/de/resume", "/de/projects", "/de/about", "/de/contact"]


def _nav_labels(driver):
    """ Visible nav-button labels, case-folded (the CSS uppercases them). """
    return {a.text.strip().casefold()
            for a in driver.find_elements(By.CSS_SELECTOR, "header a.button")}


@pytest.mark.parametrize("path", EN_PAGES + DE_PAGES)
def test_page_loads(driver, base_url, path):
    """ Every page renders and keeps the site title. """
    driver.get(base_url + path)
    assert driver.title == "perez.wiki"


def test_header_nav_present(driver, base_url):
    """ The four nav buttons render on the home page. """
    driver.get(base_url + "/")
    expected = {"Resume", "Projects", "About", "Contact"}
    assert {label.casefold() for label in expected} <= _nav_labels(driver)


def test_nav_click_navigates(driver, base_url):
    """ Clicking a nav button lands on that page. """
    driver.get(base_url + "/")
    driver.find_element(By.CSS_SELECTOR, 'header a.button[href="/projects"]').click()
    assert driver.current_url.rstrip("/").endswith("/projects")


def test_german_nav_present(driver, base_url):
    """ The German home page renders the German nav labels. """
    driver.get(base_url + "/de")
    expected = {"Lebenslauf", "Projekte", "Über mich", "Kontakt"}
    assert {label.casefold() for label in expected} <= _nav_labels(driver)
