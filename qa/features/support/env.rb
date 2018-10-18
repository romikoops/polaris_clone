# frozen_string_literal: true

require 'capybara/cucumber'
require 'chronic'
require 'cucumber'
require 'selenium-webdriver'

Capybara.default_driver = ENV.fetch('DRIVER', 'chrome').to_sym
Capybara.save_path = ENV.fetch('REPORT_PATH', 'report/')
Capybara.default_max_wait_time = 10
