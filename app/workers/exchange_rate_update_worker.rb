# frozen_string_literal: true

class ExchangeRateUpdateWorker
  include Sidekiq::Worker

  BASE_CURRENCIES = %w[EUR USD].freeze

  def perform
    last_updated_at = Time.zone.now
    new_rates = BASE_CURRENCIES.flat_map do |base|
      bank_for_base_currency(base: base).update_rates.map do |key, rate|
        {
          from: base,
          to: key,
          rate: rate,
          created_at: last_updated_at,
          updated_at: last_updated_at
        }
      end
    end
    Treasury::ExchangeRate.import(new_rates)
  end

  def bank_for_base_currency(base:)
    Money::Bank::OpenExchangeRatesBank.new.tap do |bank|
      bank.app_id = Settings.open_exchange_rate.app_id
      bank.source = base
    end
  end
end

Sidekiq::Cron::Job.create(
  name: "Exchange Rate Update worker - every morning",
  cron: "0 2 * * *",
  class: "ExchangeRateUpdateWorker"
)
