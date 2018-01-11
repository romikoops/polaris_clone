module CurrencyTools
  require "http"
  def get_rates(base)
    cached_rates = Currency.find_by_base(base)
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
      results.push({key: k, rate: v})
    end
    return results
  end

  def sum_and_convert(hash_obj, base)
    
    rates = get_rates(base)
    base_value = 0
    hash_obj.each do |key, value|
      if rates[:today][key]
        base_value += value * (1/rates[:today][key])
      elsif key == base
        base_value += value
      end
    end
    
    base_value
  end

  def sum_and_convert_cargo(hash_obj, base)
    
    rates = get_rates(base)
    base_value = 0
    hash_obj.each do |key, charge|
      if rates[:today][charge["currency"]]
        base_value += charge["value"] * (1/rates[:today][charge["currency"]])
      elsif charge["currency"] == base
        base_value += charge["value"]
      end
    end
    
    base_value
  end

  def refresh_rates(base)
    curr_obj = Currency.find_by_base(base)
    rates = JSON.parse(HTTP.get("https://api.fixer.io/latest?base=#{base}").to_s)
    if !curr_obj
      curr_obj = Currency.create(today: rates["rates"], base: base)
    else
      curr_obj.update_attributes(today: rates["rates"])
    end
    curr_obj
  end

end