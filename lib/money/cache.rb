# frozen_string_literal: true

require 'money/rates_store/memory'
require 'money/bank/open_exchange_rates_bank'

class MoneyCache
  BASE_CURRENCIES = %w[GBP USD EUR CNY AED].freeze
  def initialize(ttl: 6.hours)
    @ttl = ttl
    @last_updated_at = Time.zone.now
  end

  delegate :add_rate, to: :store

  def get_rate(from_currency, to_currency, opts = {})
    rate = get_rate_or_calc_inverse(from_currency, to_currency, opts)
    rate || calc_pair_rate_using_base(from_currency, to_currency, opts)
  end

  def store
    return create_store if @current_store.nil?

    @current_store
  end

  private

  def bank
    @bank ||= Money::Bank::OpenExchangeRatesBank.new(store)
  end

  def create_store
    @current_store = Money::RatesStore::Memory.new
    refresh_rates
    update_store

    @current_store
  end

  def update_store
    ExchangeRate.current.each do |exchange_rate|
      @current_store.add_rate(exchange_rate.from, exchange_rate.to, exchange_rate.rate)
    end
  end

  def refresh_rates
    bank.app_id = Settings.open_exchange_rate.app_id
    bank.update_rates
    new_rates = bank.rates.map do |key, rate|
      from, to = key.split('_TO_')
      expand_rate(from_currency: from, to_currency: to, rate: rate)
    end
    ExchangeRate.import(new_rates)
    @last_updated_at = Time.zone.now
  end

  def expand_rate(from_currency:, to_currency:, rate:)
    {
      from: from_currency,
      to: to_currency,
      rate: rate,
      created_at: @last_updated_at,
      updated_at: @last_updated_at
    }
  end

  def get_rate_or_calc_inverse(from_currency, to_currency, _opts = {})
    rate = store.get_rate(from_currency, to_currency)
    unless rate
      inverse_rate = store.get_rate(to_currency, from_currency)
      if inverse_rate
        rate = 1.0 / inverse_rate
        add_rate(from_currency, to_currency, rate)
      end
    end
    rate
  end

  def calc_pair_rate_using_base(from_currency, to_currency, opts)
    from_base_rate = get_rate_or_calc_inverse(bank.source, from_currency, opts)
    to_base_rate   = get_rate_or_calc_inverse(bank.source, to_currency, opts)
    return unless to_base_rate
    return unless from_base_rate

    rate = BigDecimal(to_base_rate.to_s) / from_base_rate
    add_rate(from_currency, to_currency, rate)
    rate
  end
end
