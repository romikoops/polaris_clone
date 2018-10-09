# ItsMyCargo QA

This directory holds high level, "happy-path" testing of functioanlity of the app.
It uses Cucumber tests and capybara with real, click-through browser (Chrome).

## Setup

Ensure old `chromedriver-helper` gem is not installed. List all installed versions with:

    $ gem list --local chromedriver-helper

If you see anything else than `2.1.0` or newer installed, then run

    $ gem uninstall -ax chromedriver-helper

Run bundle to install all required gems:

    $ bundle install

## Run tests

To run full feature suite against `https://demo.itsmycargo.com`, simple run:

    $ bin/cucumber

To run against different server, simply set `TARGET_URL=...` environment variable, e.g.

    $ TARGET_URL=http://localhost:8080 bin/cucumber
