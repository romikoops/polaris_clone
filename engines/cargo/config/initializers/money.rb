# frozen_string_literal: true

require 'money-rails'

MoneyRails.configure do |config|
  config.locale_backend = :i18n
end
