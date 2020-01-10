# encoding : utf-8
require 'money-rails'

MoneyRails.configure do |config|
  config.locale_backend = :i18n
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
end
