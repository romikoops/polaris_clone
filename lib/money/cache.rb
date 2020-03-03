# frozen_string_literal: true

require 'money/rates_store/memory'
require 'eu_central_bank'

class MoneyCache
  BASE_CURRENCIES = %w[GBP USD EUR CNY].freeze
  def initialize(ttl: 6.hours)
    @ttl = ttl
    @last_updated_at = Time.zone.now
  end

  delegate :get_rate, :add_rate, to: :store

  def store
    return create_store if @current_store.nil?

    @current_store
  end

  def update_store
    ExchangeRate.current.each do |exchange_rate|
      add_rate(exchange_rate.from, exchange_rate.to, exchange_rate.rate)
    end
  end

  def update_rates
    bank = EuCentralBank.new
    created_at = Time.zone.now
    bank.update_rates
    new_rates = bank.rates.map do |key, rate|
      from, to = key.split('_TO_')
      { from: from, to: to, rate: rate, created_at: created_at, updated_at: bank.last_updated }
    end
    expanded_rates = expand_rates(rates: new_rates.dup).compact
    ExchangeRate.import(expanded_rates)
    @last_updated_at = bank.last_updated
  end

  def expand_rates(rates:)
    BASE_CURRENCIES.flat_map do |base|
      base_rate = rates.find { |exchange_rate| exchange_rate.slice(:from, :to) == { to: base, from: 'EUR' } }
      rates_for_base = rates.map do |exchange_rate|
        next if exchange_rate[:from] == exchange_rate[:to]

        if base == 'EUR'
          exchange_rate
        else
          adjusted_rate = exchange_rate.dup
          adjusted_rate[:rate] = adjusted_rate[:from] == base ? 1 : (1 / base_rate[:rate]) * adjusted_rate[:rate]
          adjusted_rate[:from] = base
          adjusted_rate
        end
      end
      rates_for_base << base_rate.merge(from: base_rate[:to], to: base_rate[:from], rate: (1 / base_rate[:rate]))
      rates_for_base
    end
  end

  def create_store
    update_rates
    @current_store = Money::RatesStore::Memory.new
    update_store

    @current_store
  end

  attr_accessor :current_store, :last_updated_at
end
