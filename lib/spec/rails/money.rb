# frozen_string_literal: true

begin
  require 'money-rails'

  MoneyRails.configure do |config|
    config.locale_backend = :i18n
    config.default_bank = Money::Bank::VariableExchange.new(Money::RatesStore::Memory.new)
    config.default_bank.add_rate('USD', 'EUR', (1 / 1.26))
    config.default_bank.add_rate('USD', 'SEK', 8.2)
    config.default_bank.add_rate('USD', 'CNY', 7.1)
    config.default_bank.add_rate('EUR', 'USD', 1.26)
    config.default_bank.add_rate('EUR', 'SEK', 0.18)
    config.default_bank.add_rate('EUR', 'CNY', 0.29)
    config.default_currency = 'EUR'
    Money.infinite_precision = true
    config.rounding_mode = BigDecimal::ROUND_HALF_UP
  end
rescue LoadError # rubocop:disable Lint/SuppressedException
end
