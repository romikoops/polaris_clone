# frozen_string_literal: true
class ExchangeRateUpdateWorker
  include Sidekiq::Worker

  def perform(*args)
    last_updated_at = Time.zone.now
    new_rates = bank.update_rates.map { |key, rate|
      {
        from: bank.source,
        to: key,
        rate: rate,
        created_at: last_updated_at,
        updated_at: last_updated_at
      }
    }
    Treasury::ExchangeRate.import(new_rates)
  end

  def bank
    @bank ||= Money::Bank::OpenExchangeRatesBank.new.tap do |bank|
      bank.app_id = Settings.open_exchange_rate.app_id
      bank.source = "EUR"
    end
  end
end

Sidekiq::Cron::Job.create(
  name: "Exchange Rate Update worker - every morning",
  cron: "0 2 * * *",
  class: "ExchangeRateUpdateWorker"
)
