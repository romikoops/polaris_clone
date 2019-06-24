# frozen_string_literal: true

require 'net/http'
module Pricings
  class Conversion
    def initialize(base:, tenant_id:)
      @tenant = ::Legacy::Tenant.find(tenant_id)
      @base = base
      @scope = @tenant.scope
      @rates = get_rates(@base)
    end

    def get_rates(target)
      if @scope['fixed_exchange_rates']
        tenant_id_for_update = @tenant.id
        tenant_rates = ::Legacy::Currency.find_by(base: target, tenant_id: tenant_id_for_update)
        cached_rates = tenant_rates || ::Legacy::Currency.find_by(base: target)
      else
        tenant_id_for_update = nil
        cached_rates = ::Legacy::Currency.find_by(base: target, tenant_id: nil)
      end

      if cached_rates.nil? || cached_rates.today.nil? || cached_rates.updated_at < Date.today - 1.day
        cached_rates = refresh_rates(target, tenant_id_for_update)
      end
      cached_rates
    end

    def sum_and_convert(hash_obj)
      base_value = 0
      hash_obj.each do |key, value|
        if key == @base
          base_value += value
        elsif @rates[:today][key]
          base_value += value * (1 / @rates[:today][key])
        end
      end

      round_value(base_value)
    end

    def convert(value, from, to)
      rates = get_rates(to)
      base_value = 0
      if from == to
        base_value += value
      elsif rates[:today][from]
        base_value += value * (1 / rates[:today][from])
      end

      base_value
    end

    def sum_and_convert_cargo(hash_obj)
      base_value = 0
      hash_obj.each do |_key, charge|
        if charge['currency'] == @base
          base_value += charge['value']
        elsif @rates[:today][charge['currency']]
          base_value += charge['value'] * (1 / @rates[:today][charge['currency']])
        end
      end
      round_value(base_value)
    end

    def refresh_rates(target, tenant_id_for_update)
      currency_obj = ::Legacy::Currency.find_by(base: target, tenant_id: tenant_id_for_update)
      return currency_obj if Settings.dig(:fixer, :api_key).nil?

      url = URI("http://data.fixer.io/latest?access_key=#{Settings.fixer.api_key}&base=#{target}")
      response = JSON.parse(Net::HTTP.get(url))
      rates = response['rates']

      if !currency_obj
        currency_obj = Legacy::Currency.create(today: rates, base: target, tenant_id: tenant_id_for_update)
      else
        currency_obj.update_attributes(today: rates)
      end

      currency_obj
    end

    def round_value(result)
      if @scope['continuous_rounding']
        result.to_d.round(2)
      else
        result
      end
    end
  end
end
