# frozen_string_literal: true

require "money/rates_store/memory"
require "money/bank/open_exchange_rates_bank"
require "active_support/time"
require_relative "./conversion"

module MoneyCache
  class Converter
    def initialize(ttl: 6.hours, klass: nil, date: nil, config: {})
      @ttl = ttl
      @date = date
      @klass = klass
      @config = config
      @last_updated_at = Time.at(0).utc
    end

    def get_rate(from_currency, to_currency)
      MoneyCache::Conversion.rate(from: from_currency, to: to_currency, store: current_store, base: bank.source)
    end

    def store
      @store ||= Money::RatesStore::Memory.new
    end

    private

    attr_reader :klass, :date, :config, :last_updated_at

    def current_store
      rates = if date.present?
        klass.for_date(date: date)
      elsif last_updated_at < cache_time_window
        klass.current
      end

      if rates.present?
        rates.each do |exchange_rate|
          store.add_rate(exchange_rate.from, exchange_rate.to, exchange_rate.rate)
        end
        @last_updated_at = DateTime.now.utc
      end

      store
    end

    def bank
      Money::Bank::OpenExchangeRatesBank.new(store).tap do |bank|
        bank.app_id = config.dig(:bank_app_id)
      end
    end

    def cache_time_window
      DateTime.now.utc - 24.hours
    end
  end
end
