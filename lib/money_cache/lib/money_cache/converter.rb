# frozen_string_literal: true

require "money/rates_store/memory"
require "money/bank/open_exchange_rates_bank"
require "active_support/time"
require_relative "./conversion"

module MoneyCache
  class Converter
    def initialize(ttl: 6.hours, klass: nil, date: nil, config: {})
      @ttl = ttl
      @last_updated_at = DateTime.now
      @date = date
      @klass = klass
      @config = config
    end

    def get_rate(from_currency, to_currency)
      MoneyCache::Conversion.rate(from: from_currency, to: to_currency, store: current_store, base: bank.source)
    end

    def store
      @store ||= Money::RatesStore::Memory.new
    end

    delegate :add_rate, to: :store

    private

    attr_reader :klass, :date, :last_updated_at

    def bank
      @bank ||= Money::Bank::OpenExchangeRatesBank.new(store).tap do |bank|
        bank.app_id = @config.dig(:bank_app_id)
      end
    end

    def refresh_rates
      bank.update_rates
      new_rates = bank.rates.map { |key, rate|
        from, to = key.split("_TO_")
        expand_rate(from_currency: from, to_currency: to, rate: rate)
      }
      import_result = klass.import(new_rates)
      @last_updated_at = DateTime.now if import_result.failed_instances.empty?
    end

    def expand_rate(from_currency:, to_currency:, rate:)
      {
        from: from_currency,
        to: to_currency,
        rate: rate,
        created_at: last_updated_at,
        updated_at: last_updated_at
      }
    end

    def rates
      @rates ||= if date.present?
        klass.where("created_at < ?", date).order(created_at: :asc)
      else
        klass.current
      end
    end

    def current_store
      @current_store ||= begin
        refresh_rates if should_refresh_rates?

        rates.each do |exchange_rate|
          store.add_rate(exchange_rate.from, exchange_rate.to, exchange_rate.rate)
        end

        store
      end
    end

    def should_refresh_rates?
      date.blank? || !klass.where("created_at > ?", 6.hours.ago).exists?
    end
  end
end
