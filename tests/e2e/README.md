# E2E tests

Selenium smoke tests for the site. Run by the Jenkins pipeline (`../../Jenkinsfile`).

## Environmental Variables

- `E2E_BASE_URL` - site to test. Defaults to `http://localhost:5000`.
- `SELENIUM_REMOTE_URL` - remote Selenium grid (e.g. `http://chrome:4444/wd/hub`).