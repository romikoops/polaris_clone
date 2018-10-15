# ItsMyCargo QA

This directory holds high level, "happy-path" testing of functionality of the app.
It uses Cucumber tests and capybara with real, click-through browser (Chrome).

## Setup

Ensure old `chromedriver-helper` gem is not installed. List all installed versions with:

    $ gem list --local chromedriver-helper

If you see anything else than `2.1.0` or newer installed, then run

    $ gem uninstall -ax chromedriver-helper

Run bundle to install all required gems:

    $ bundle install

## Run tests

To run full feature suite against `https://demo.itsmycargo.com`, simply run:

    $ bin/cucumber

To run against different server, simply set `TARGET_URL=...` environment variable, e.g.

    $ TARGET_URL=localhost:8080 bin/cucumber

`TARGET_URL` takes only the base domain name, without subdomain. This is cause subdomain is set dynamicaly per
feature/scenario depending on required enabled feature set for each tenant.
