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
    
  end

  def sum_and_convert(hash_obj, base)
    
    rates = get_rates(base)
    base_value = 0
    hash_obj.each do |key, value|
      if rates[:today][key]
        
        base_value += value * (1/rates[:today][key])
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