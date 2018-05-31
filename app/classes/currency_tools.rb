module CurrencyTools
  require "http"

  def get_rates(base)
    cached_rates = Currency.find_by(base: base)

    if !cached_rates
      rates = refresh_rates(base)
    elsif cached_rates.updated_at < Date.new() - 1.day
      rates = refresh_rates(base)
    else
      rates = cached_rates
    end

    return rates
  end

  def get_currency_array(base)
    rates = get_rates(base)
    results = [{key: base, rate: 1}]
    rates["today"].each do |k, v|
      results << {key: k, rate: v}
    end

    return results
  end

  def sum_and_convert(hash_obj, base)
    rates = get_rates(base)
    base_value = 0
    hash_obj.each do |key, value|
      if rates[:today][key]
        base_value += value * (1 / rates[:today][key])
      elsif key == base
        base_value += value
      end
    end

    return base_value
  end

  def sum_and_convert_cargo(hash_obj, base)
    rates = get_rates(base)
    base_value = 0

    hash_obj.each do |key, charge|
      if rates[:today][charge["currency"]]
        base_value += charge["value"] * (1 / rates[:today][charge["currency"]])
      elsif charge["currency"] == base
        base_value += charge["value"]
      end
    end

    return base_value
  end

  def refresh_rates(base)
    currency_obj = Currency.find_by(base: base)
    # old___response = JSON.parse(HTTP.get("https://api.fixer.io/latest?base=#{base}").to_s)
    url = "http://data.fixer.io/latest?access_key=#{ENV["FIXER_API_KEY"]}&base=#{base}"
    response = JSON.parse(HTTP.get(url).to_s)
    rates = response["rates"]

    if !currency_obj
      currency_obj = Currency.create(today: rates, base: base)
    else
      currency_obj.update_attributes(today: rates)
    end

    return currency_obj
  end

  def refresh_rates_array(base)
    currency_obj = refresh_rates(base)

    results = [{key: base, rate: 1}]
    currency_obj.today.each do |k, v|
      results << {key: k, rate: v}
    end

    return results
  end
end
