# frozen_string_literal: true

require 'capybara-screenshot/cucumber'
require 'capybara/cucumber'
require 'chronic'
require 'cucumber'
require 'selenium-webdriver'

# Load all support
# Dir[File.expand_path('**/*.rb', __dir__)].each { |f| require f }

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :remote_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    takesScreenshot: true
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, url: ENV['SELENIUM_URL'], desired_capabilities: capabilities)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    takesScreenshot: true,
    chromeOptions: { args: %w(headless) }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.default_driver = ENV.fetch('DRIVER', 'chrome').to_sym
# Capybara.default_max_wait_time = 30

Capybara::Screenshot.autosave_on_failure = false

Before do |scenario|
  @scenario = scenario
  @step_index = 0

  # Connect to correct subdomain
  tags = scenario.tags.map(&:name)
  subdomain = Helpers.subdomain_for_features(tags: tags)
  Capybara.app_host = Helpers.app_host(subdomain: subdomain || 'demo')
end

AfterStep do
  @step_index += 1
end

After do |scenario|
  if scenario.failed?
    take_screenshot(name: scenario.name)
    print_console_log
  end
end
