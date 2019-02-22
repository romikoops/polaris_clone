# frozen_string_literal: true

class TruckingPriceRulesMachine
  attr_reader :total_price

  def initialize(pricing, km, weight_in_tons, volume_in_cm3, units, zip_code = 1000)
    @total_price = rule_evaluation(pricing, km.to_f, weight_in_tons.to_f, volume_in_cm3.to_f, units.to_i, zip_code)
  end

  def rule_evaluation(pricing, km, weight_in_tons, volume_in_cm3, units, zip_code)
    if volume_in_cm3 / 1_000_000 > pricing.fcl_limit_m3_40_foot || weight_in_tons > pricing.fcl_limit_tons_40_foot
      raise 'Volume and/or weight are out of bounds!'
      return false
    end

    # if volume_in_cm3 / 1000000 == pricing.fcl_limit_m3_40_foot || weight_in_tons == pricing.fcl_limit_tons_40_foot
    #   return pricing.fcl_price
    # end

    if pricing.has_steptable?
      steptable_price(pricing, weight_in_tons, volume_in_cm3, units, zip_code)
    else
      formula_price(pricing, km, weight_in_tons, volume_in_cm3, units)
    end
  end

  private

  def formula_price(pricing, km, weight_in_tons, volume_in_cm3, units)
    price1 = weight_in_tons * pricing.price_per_ton * units + km * pricing.price_per_km

    price2 = volume_in_cm3 / 1_000_000 * pricing.price_per_m3 * units + km * pricing.price_per_km

    total_price = price1 > price2 ? price1 : price2
  end

  def steptable_price(pricing, weight_in_tons, volume_in_cm3, units, zip_code)
    table = pricing.steptable
    weight = weight_in_tons * units
    volume = volume_in_cm3 / 1_000_000 * units

    multiplier = determine_mulitplier(weight, volume)

    price_per_part = nil
    table.keys.each do |zip_code_range_string|
      zip_code_range_array = JSON.parse(zip_code_range_string)
      next unless zip_code.between?(zip_code_range_array.first, zip_code_range_array.last)

      table[zip_code_range_string].keys.each do |multiplier_range_string|
        multiplier_range_array = JSON.parse(multiplier_range_string)
        if multiplier.between?(multiplier_range_array.first, multiplier_range_array.last)
          price_per_part = table[zip_code_range_string][multiplier_range_string]
        end
      end
      price_per_part = table[zip_code_range_string][table[zip_code_range_string].keys.last] if price_per_part.nil?
    end

    total_price = multiplier * price_per_part

    total_price = pricing.steptable_min_price if total_price < pricing.steptable_min_price

    total_price
  end

  def determine_mulitplier(weight, volume)
    if volume >= weight * 1000 / 333
      volume
    else
      weight * 1000 / 333
    end
  end
end
