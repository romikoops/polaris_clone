# frozen_string_literal: true

require 'capybara/cucumber'
require 'chronic'
require 'cucumber'
require 'selenium-webdriver'
require 'ffaker'

Capybara.default_driver = ENV.fetch('DRIVER', 'chrome').to_sym
Capybara.save_path = ENV.fetch('REPORT_PATH', 'report/')
Capybara.default_max_wait_time = 30

Capybara.app_host = ENV.fetch('TARGET_URL', 'http://192.168.8.100:8080')
Capybara.asset_host = Capybara.app_host
