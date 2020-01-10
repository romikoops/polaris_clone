# frozen_string_literal: true

require 'net/http'

module Legacy
  class CurrencyTools
    def get_rates(base, tenant_id)
      cached_rates = Legacy::Currency.find_by(base: base, tenant_id: tenant_id)

      if cached_rates.nil? || cached_rates.today.nil? || cached_rates.updated_at < Date.yesterday
        cached_rates = refresh_rates(base, nil)
      end

      cached_rates
    end

    def get_currency_array(base, tenant_id)
      rates = get_rates(base, tenant_id)
      results = [{ key: base, rate: 1 }]

      rates['today'].each do |k, v|
        results << { key: k, rate: v }
      end

      results
    end

    def sum_and_convert(hash_obj, base, tenant_id)
      rates = get_rates(base, tenant_id)
      base_value = 0
      hash_obj.each do |key, value|
        if key == base
          base_value += value
        elsif rates[:today][key]
          base_value += value * (1 / rates[:today][key])
        end
      end

      base_value
    end

    def convert(value, from, to, tenant_id)
      return value if from == to

      rates = get_rates(to, tenant_id)
      base_value = 0
      if rates[:today][from]
        base_value += value * (1 / rates[:today][from])
      end
      base_value
    end

    def sum_and_convert_cargo(hash_obj, base, tenant_id)
      rates = get_rates(base, tenant_id)
      base_value = 0
      hash_obj.each do |_key, charge|
        if charge['currency'] == base
          base_value += charge['value']
        elsif rates[:today][charge['currency']]
          base_value += charge['value'] * (1 / rates[:today][charge['currency']])
        end
      end

      base_value
    end

    def refresh_rates(base, tenant_id)
      exchange_rates = Legacy::Currency.find_by(base: base, tenant_id: tenant_id)
      url = URI("http://data.fixer.io/latest?access_key=#{Settings.fixer&.api_key}&base=#{base}")
      response = JSON.parse(Net::HTTP.get(url))
      rates = response['rates']
      return if rates.nil?

      if !exchange_rates
        exchange_rates = Legacy::Currency.create(today: rates, base: base, tenant_id: tenant_id)
      else
        exchange_rates.update(today: rates)
      end

      exchange_rates
    end

    def refresh_rates_array(base, tenant_id = nil)
      currency_obj = refresh_rates(base, tenant_id)

      results = [{ key: base, rate: 1 }]
      currency_obj.today.each do |k, v|
        results << { key: k, rate: v }
      end

      results
    end
  end
end
