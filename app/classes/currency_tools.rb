# frozen_string_literal: true

module CurrencyTools
  require 'http'

  def get_rates(base, tenant_id)
    tenant = Tenant.find(tenant_id)
    if tenant && tenant.scope['fixed_exchange_rates']
      tenant_rates = Currency.find_by(base: base, tenant_id: tenant_id)
      cached_rates = tenant_rates || Currency.find_by(base: base)
    else
      cached_rates = Currency.find_by(base: base, tenant_id: nil)
    end
   
    if cached_rates.nil? || cached_rates.today.nil? || cached_rates.updated_at < Date.today - 1.day
      cached_rates = refresh_rates(base)
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
      if rates[:today][key]
        base_value += value * (1 / rates[:today][key])
      elsif key == base
        base_value += value
      end
    end

    round_value(base_value, tenant_id)
  end

  def convert(value, from, to, tenant_id)
    rates = get_rates(to, tenant_id)
    base_value = 0
    if rates[:today][from]
      base_value += value * (1 / rates[:today][from])
    elsif from == to
      base_value += value
    end

    base_value
  end

  def sum_and_convert_cargo(hash_obj, base, tenant_id)
    rates = get_rates(base, tenant_id)
    base_value = 0
    hash_obj.each do |_key, charge|
      if rates[:today][charge['currency']]
        base_value += charge['value'] * (1 / rates[:today][charge['currency']])
      elsif charge['currency'] == base
        base_value += charge['value']
      end
    end
    round_value(base_value, tenant_id)
  end

  def refresh_rates(base)
    currency_obj = Currency.find_by(base: base)
    url = "http://data.fixer.io/latest?access_key=#{Settings.fixer.api_key}&base=#{base}"
    response = JSON.parse(HTTP.get(url).to_s)
    rates = response['rates']

    if !currency_obj
      currency_obj = Currency.create(today: rates, base: base)
    else
      currency_obj.update_attributes(today: rates)
    end

    currency_obj
  end

  def refresh_rates_array(base)
    currency_obj = refresh_rates(base)

    results = [{ key: base, rate: 1 }]
    currency_obj.today.each do |k, v|
      results << { key: k, rate: v }
    end

    results
  end

  def round_value(result, tenant_id)
    if Tenant.find(tenant_id).scope['continuous_rounding']
      result.to_d.round(2)
    else
      result
    end
  end
end
