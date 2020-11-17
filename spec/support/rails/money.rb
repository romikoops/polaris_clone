# frozen_string_literal: true

require "money-rails"

MoneyRails.configure do |config|
  config.locale_backend = :i18n
  config.default_bank = Money::Bank::VariableExchange.new(Money::RatesStore::Memory.new)
  config.default_bank.add_rate("USD", "EUR", (1 / 1.26))
  config.default_bank.add_rate("USD", "SEK", 8.2)
  config.default_bank.add_rate("USD", "CNY", 7.1)
  config.default_bank.add_rate("EUR", "USD", 1.26)
  config.default_bank.add_rate("EUR", "SEK", 8)
  config.default_bank.add_rate("SEK", "EUR", 0.125)
  config.default_bank.add_rate("EUR", "AED", 1.34)
  config.default_bank.add_rate("EUR", "CNY", 0.29)
  config.default_bank.add_rate("CNY", "EUR", (1 / 0.29))
  config.default_bank.add_rate("CNY", "SEK", (1 / 0.29) * 0.125)
  config.default_bank.add_rate("SEK", "CNY", 0.29 * 8)
  config.default_currency = "EUR"
  Money.infinite_precision = true
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
end
