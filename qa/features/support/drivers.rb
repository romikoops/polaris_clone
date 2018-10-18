# frozen_string_literal: true

#
# Local Development / Browsers
##############################
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    takesScreenshot: true,
    chromeOptions: { args: %w(headless) }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
end

#
# Remote / CI / Cross-Browser
#############################
Capybara.register_driver :remote do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.new(
    browser_name: ENV.fetch('BROWSERNAME'),
    javascript_enabled: true,
    takes_screenshot: true,
    css_selectors_enabled: true
  )

  Capybara::Selenium::Driver.new(app,
                                 browser: ENV.fetch('BROWSERNAME').to_sym,
                                 url: ENV['SELENIUM_URL'],
                                 desired_capabilities: capabilities)
end

Capybara.register_driver :crossbrowser do |app|
  username = ENV.fetch('CROSSBROWSER_USERNAME', '').sub('@', '%40')
  authkey = ENV.fetch('CROSSBROWSER_AUTHKEY', '')

  crossbrowser_url = "http://#{username}:#{authkey}@hub.crossbrowsertesting.com/wd/hub"
  capabilities = Selenium::WebDriver::Remote::Capabilities.new(
    name: ENV['CI_COMMIT_REF_SLUG'],
    build: ENV['CI_COMMIT_SHA'],
    max_duration: ENV.fetch('CROSSBROWSER_MAX_DURATION', 1800), # 30min

    nativeEvents: true
  )

  capabilities['browserName'] = ENV.fetch('CROSSBROWSER_BROWSERNAME', 'chrome').tr('_', ' ')
  capabilities['version'] = ENV.fetch('CROSSBROWSER_VERSION', 'latest').tr('_', ' ')
  capabilities['platform'] = ENV.fetch('CROSSBROWSER_PLATFORM', '').tr('_', ' ')

  Capybara::Selenium::Driver.new(app, browser: :remote, url: crossbrowser_url, desired_capabilities: capabilities)
end
