# frozen_string_literal: true

require 'bigdecimal'

module TruckingTools
  module_function

  LoadMeterageExceeded = Class.new(StandardError)

  LOAD_METERAGE_AREA_DIVISOR = 24_000
  CBM_VOLUME_DIVISOR = 1_000_000
  DEFAULT_MAX = 1_000_000
  def calculate_trucking_price(pricing, cargo, _direction, km, scope)
    fees = {}
    result = {}
    total_fees = {}
    return {} if pricing.empty?

    pricing.deep_symbolize_keys!
    pricing[:fees].each do |k, fee|
      if fee[:rate_basis] != 'PERCENTAGE'
        results = fare_calculator(k, fee, cargo, km, scope)
        fees[k] = results
      else
        total_fees[k] = fee
      end
    end
    fees[:rate] = fare_calculator('rate', pricing[:rate], cargo, km, scope)

    fees.each do |_k, fee|
      next unless fee
      if !result['value']
        result['value'] = fee[:value]
      else
        result['value'] += fee[:value]
      end
      result['currency'] = fee[:currency]
    end
    extra_fees_results = {}

    total_fees.each do |tk, tfee|
      extra_fees_results[tk] = tfee[:value] * fees[:rate][:value]
    end

    extra_fees_results.each do |_ek, evalue|
      result['value'] += evalue
    end

    if !pricing['min_value'] || (pricing['min_value'] && result['value'] > pricing['min_value'])
      return { value: result['value'], currency: result['currency'] }
    else
      return { value: pricing['min_value'], currency: result['currency'] }
    end
  end

  def fare_calculator(key, fee, cargo, km, scope)
    fee.symbolize_keys!

    fare = case fee[:rate_basis]
           when 'PER_KG'

             val = cargo['weight'] * fee[:value]
             min = fee[:min_value] || 0
             [val, min].max

           when 'PER_X_KG'
             val = (cargo['weight'] / fee[:base]) * fee[:value]
             min = fee[:min_value] || 0
             [val, min].max

           when 'PER_X_KM'
             val = ((km / fee[:x_base]) * fee[:rate]) + fee[:base_value]
             min = fee[:min_value] || 0
             [val, min].max
           when 'PER_X_TON'
             val = ((cargo['weight'] / 1000) / fee[:base]) * fee[:value]
             min = fee[:min_value] || 0
             [val, min].max
           when 'PER_SHIPMENT'
             fee[:value]
           when 'PER_BILL'
             fee[:value]
           when 'PER_ITEM'
             fee[:value] * cargo['number_of_items']
           when 'PER_CONTAINER'
             fee[:value] * cargo['number_of_items']
           when 'PER_CONTAINER_KM'
             value = ((fee[:km] * km) + fee[:unit]) * cargo['number_of_items']
             min = fee[:min_value] || 0
             [min, value].max

           when 'PER_CBM_TON'
             cbm_value = cargo['volume'] * fee[:cbm]
             ton_value = (cargo['weight'] / 1000) * fee[:ton]
             min = fee[:min_value] || 0
             [ton_value, cbm_value, min].max
           when 'PER_CBM'
             cbm_value = cargo['volume'] * (fee[:value] || fee[:cbm])
             min = fee[:min_value] || 0
             [cbm_value, min].max

           when 'PER_WM'
             value = (cargo['weight'] / 1000) * fee[:value]
             min = fee[:min_value] || 0
             [value, min].max

           when 'PER_CBM_KG'
             cbm_value = cargo['volume'] * fee[:cbm]
             kg_value = cargo['weight'] * fee[:kg]
             min = fee[:min_value] || 0
             [kg_value, cbm_value].max

           when /RANGE/
             handle_range_fare(fee, cargo)
    end

    final_result = round_fare(fare, scope['continuous_rounding'])
    { currency: fee[:currency], value: final_result, key: key }
  end

  def handle_range_fare(fee, cargo)
    weight_kg = cargo[:weight]
    min = fee['min'] || 0
    result = case fee[:rate_basis]
             when 'PER_KG_RANGE'
               fee_range = fee[:range].find do |range|
                 weight_kg >= range[:min] && weight_kg <= range[:max]
               end
               value = fee_range.nil? ? 0 : fee_range[:rate] * weight_kg
               [value, min].max
             when 'PER_CONTAINER_RANGE'
               fee_range = fee[:range].find do |range|
                 weight_kg >= range[:min] && weight_kg <= range[:max]
               end

               value = fee_range.nil? ? 0 : fee_range[:rate]
               [value, min].max
    end

    result
  end

  def filter_trucking_pricings(trucking_pricing, cargo_values, _direction)
    scope = trucking_pricing.tenant.scope
    return {} if cargo_values['weight'].to_i == 0

    case trucking_pricing.modifier
    when 'kg'
      if cargo_values['weight'].to_i > trucking_pricing['rates']['kg'].last['max_kg'].to_i && scope['hard_trucking_limit']
        raise TruckingTools::LoadMeterageExceeded
      elsif cargo_values['weight'].to_i > trucking_pricing['rates']['kg'].last['max_kg'].to_i && !scope['hard_trucking_limit']
        rate = trucking_pricing['rates']['kg'].last
        rate['rate']['min_value'] = rate['min_value']
        return { rate: rate['rate'], fees: trucking_pricing['fees'] }
      end
      trucking_pricing['rates']['kg'].each do |rate|
        if cargo_values['weight'].to_i <= rate['max_kg'].to_i && cargo_values['weight'].to_i >= rate['min_kg'].to_i
          rate['rate']['min_value'] = rate['min_value']
          return { rate: rate['rate'], fees: trucking_pricing['fees'] }
        end
      end

    when 'cbm'
      trucking_pricing['rates']['cbm'].each do |rate|
        next unless cargo_values['volume'] <= rate['max_cbm'].to_i && cargo_values['volume'] >= rate['min_cbm'].to_i

        rate['rate']['min_value'] = rate['min_value']
        return { rate: rate['rate'], fees: trucking_pricing['fees'] }
      end
    when 'wm'
      trucking_pricing['rates']['wm'].each do |rate|
        rate['rate']['min_value'] = rate['min_value']
        return { rate: rate['rate'], fees: trucking_pricing['fees'] }
      end
    when 'cbm_kg'
      result = { rate_basis: 'PER_CBM_KG' }
      trucking_pricing['rates']['kg'].each do |rate|
        next unless cargo_values['weight'].to_i <= rate['max_kg'].to_i && cargo_values['weight'].to_i >= rate['min_kg'].to_i
        result['kg'] = rate['rate']['value']
        result['min_value'] = rate['min_value']
        result['currency'] = rate['rate']['currency']
      end
      trucking_pricing['rates']['cbm'].each do |rate|
        next unless cargo_values['volume'] <= rate['max_cbm'].to_i && cargo_values['volume'] >= rate['min_cbm'].to_i
        result['cbm'] = rate['rate']['value']
        result['min_value'] = rate['min_value']
        result['currency'] = rate['rate']['currency']
      end
      if cargo_values['volume'] < trucking_pricing['rates']['cbm'].first['min_cbm'].to_i
        result['cbm'] = trucking_pricing['rates']['cbm'].first['rate']['value']
        result['min_value'] = trucking_pricing['rates']['cbm'].first['min_value']
        result['currency'] = trucking_pricing['rates']['cbm'].first['rate']['currency']
      elsif cargo_values['volume'] > trucking_pricing['rates']['cbm'].last['max_cbm'].to_i
        result['cbm'] = trucking_pricing['rates']['cbm'].last['rate']['value']
        result['min_value'] = trucking_pricing['rates']['cbm'].last['min_value']
        result['currency'] = trucking_pricing['rates']['cbm'].last['rate']['currency']
      end
      return { rate: result, fees: trucking_pricing['fees'] }
    when 'unit'
      return { rate: trucking_pricing['rates']['unit'][0]['rate'], fees: trucking_pricing['fees'] }
    when 'unit_per_km'
      result = { rate_basis: 'PER_CONTAINER_KM' }
      result[:unit] = trucking_pricing['rates']['unit'][0]['rate']['value']
      result[:km] = trucking_pricing['rates']['km'][0]['rate']['value']
      result[:min_value] = trucking_pricing['rates']['unit'][0]['min_value']
      result[:currency] = trucking_pricing['rates']['unit'][0]['rate']['currency']
      return { rate: result, fees: trucking_pricing['fees'] }
    end
    {}
  end

  def get_cargo_item_object(trucking_pricing, cargos)
    cargo_object = {
      'stackable' => {
        'volume'          => 0,
        'weight'          => 0,
        'number_of_items' => 0
      }, 'non_stackable' => {
        'volume'          => 0,
        'weight'          => 0,
        'number_of_items' => 0
      }
    }
    
    if trucking_pricing.tenant.scope.dig('consolidation', 'trucking', 'load_meterage_only')
      consolidated_load_meterage(trucking_pricing, cargo_object, cargos)
    elsif trucking_pricing.tenant.scope.dig('consolidation', 'trucking', 'calculation')
      consolidated_trucking_cargo(trucking_pricing, cargo_object, cargos)
    else
      cargos.each do |cargo|
        determine_load_meterage(trucking_pricing, cargo_object, cargo)
      end
    end

    cargo_object
  end

  def consolidated_trucking_cargo(trucking_pricing, cargo_object, cargos)
    cargo = if cargos.first.is_a? AggregatedCargo
      cargos.first
    else
      consolidate_cargo(cargos)
    end
    calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)

  end

  def consolidate_cargo(cargo_array)
    cargo = {
      id:                'ids',
      dimension_x:       0,
      dimension_y:       0,
      dimension_z:       0,
      volume:            0,
      payload_in_kg:     0,
      cargo_class:       '',
      num_of_items:      0
    }
    cargo_array.each do |cargo_unit|
      cargo[:id] += "-#{cargo_unit.id}"
      cargo[:dimension_x] += (cargo_unit.dimension_x * cargo_unit.quantity)
      cargo[:dimension_y] += (cargo_unit.dimension_y * cargo_unit.quantity)
      cargo[:dimension_z] += (cargo_unit.dimension_z * cargo_unit.quantity)
      cargo[:volume] += (cargo_unit.volume * cargo_unit.quantity)
      cargo[:payload_in_kg] += (cargo_unit.payload_in_kg * cargo_unit.quantity)
      cargo[:cargo_class] = cargo_unit.cargo_class
      cargo[:num_of_items] += cargo_unit.quantity
    end

    cargo
  end

  def consolidated_load_meterage(trucking_pricing, cargo_object, cargos)
    if cargos.first.is_a? AggregatedCargo
      total_area =  cargos.first.volume / 1.3
      non_stackable = false
    else
      total_area =  cargos.sum { |cargo| cargo.dimension_x * cargo.dimension_y * cargo.quantity }
      non_stackable = cargos.select(&:stackable).empty?
    end

    load_area_limit = trucking_pricing.load_meterage['area_limit'] || DEFAULT_MAX
    if total_area > load_area_limit || non_stackable
      cargos.each do |cargo|
        calc_cargo_load_meterage_area(trucking_pricing, cargo_object, cargo)
      end
    else
      cargos.each do |cargo|
        calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      end
    end
  end

  def get_container_object(containers)
    cargo_total_items = containers.map(&:quantity).sum
    containers.each_with_object({}) do |cargo, cargo_object|
      cargo_object["container_#{cargo.id}"] = {
        'weight'          => cargo.payload_in_kg,
        'number_of_items' => cargo.quantity
      }
    end
  end

  def calc_trucking_price(trucking_pricing, cargos, km, carriage)
    direction = carriage == 'pre' ? 'export' : 'import'
    cargo_object = if trucking_pricing.load_type == 'container'
                     get_container_object(cargos)
                   else
                     get_cargo_item_object(trucking_pricing, cargos)
    end

    trucking_pricings = {}
    scope = trucking_pricing.tenant.scope
    cargo_object.each do |stackable_type, cargo_values|
      trucking_pricings[stackable_type] = filter_trucking_pricings(trucking_pricing, cargo_values, direction)
    end

    fees = {}
    trucking_pricings.each do |key, tp|
      fees[key] = calculate_trucking_price(tp, cargo_object[key], direction, km, scope) if tp
    end

    total = { value: 0, currency: '' }
    fees.each do |_key, trucking_fee|
      next if trucking_fee.empty?

      total[:value] += trucking_fee[:value]
      total[:currency] = trucking_fee[:currency]
    end

    total[:currency] = trucking_pricing.tenant.currency if total[:currency] == '' && total[:value] == 0

    fees[:total] = total
    fees
  end

  def determine_load_meterage(trucking_pricing, cargo_object, cargo)
    if trucking_pricing.load_meterage && trucking_pricing.load_meterage['ratio']
      if cargo.is_a? AggregatedCargo
        calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      else
        if (trucking_pricing.load_meterage['height_limit'] &&
          (cargo.dimension_z > trucking_pricing.load_meterage['height_limit'])) ||
           (!cargo.stackable && trucking_pricing.load_meterage['height_limit'])
          calc_cargo_load_meterage_height(trucking_pricing, cargo_object, cargo)
        elsif (trucking_pricing.load_meterage['area_limit'] &&
          ((cargo.dimension_x * cargo.dimension_y * cargo.quantity) >= trucking_pricing.load_meterage['area_limit'])) ||
              (!cargo.stackable && trucking_pricing.load_meterage['area_limit'])
          calc_cargo_load_meterage_area(trucking_pricing, cargo_object, cargo)
        else
          calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
        end
      end
    else
      if cargo.is_a? AggregatedCargo
        calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      else
        calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      end
    end

    cargo_object
  end



  def calc_aggregated_cargo_load_meterage(trucking_pricing, cargo_object, cargo)
    load_meterage = (cargo.volume / 1.3) / 2.4
    load_meter_weight = load_meterage * trucking_pricing.load_meterage['ratio']
    trucking_chargeable_weight = load_meter_weight > cargo.weight ? load_meter_weight : cargo.weight
    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += cargo.volume
  end

  def calc_cargo_load_meterage_height(trucking_pricing, cargo_object, cargo)
    load_meterage = ((cargo.dimension_x * cargo.dimension_y) / LOAD_METERAGE_AREA_DIVISOR) * cargo.quantity
    load_meter_weight = load_meterage * trucking_pricing.load_meterage['ratio']
    cbm_var = (cargo.dimension_x * cargo.dimension_y * cargo.dimension_z * cargo.quantity) / CBM_VOLUME_DIVISOR
    cbm_weight = cbm_var * (trucking_pricing.cbm_ratio || 0)
    raw_payload = cargo.payload_in_kg * cargo.quantity

    trucking_chargeable_weight = [load_meter_weight, raw_payload, cbm_weight].max
    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += cargo.volume * cargo.quantity
    cargo_object['non_stackable']['number_of_items'] += cargo.quantity
  end

  def calc_cargo_load_meterage_area(trucking_pricing, cargo_object, cargo)
    load_meter_var = (cargo.dimension_x * cargo.dimension_y * cargo.quantity) / LOAD_METERAGE_AREA_DIVISOR
    load_meter_weight = load_meter_var * trucking_pricing.load_meterage['ratio']
    cbm_var = (cargo.dimension_x * cargo.dimension_y * cargo.dimension_z * cargo.quantity) / CBM_VOLUME_DIVISOR
    cbm_weight = cbm_var * (trucking_pricing.cbm_ratio || 0)
    raw_payload = cargo.payload_in_kg * cargo.quantity
    trucking_chargeable_weight = [load_meter_weight, raw_payload, cbm_weight].max

    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += cargo.volume * cargo.quantity
    cargo_object['non_stackable']['number_of_items'] += cargo.quantity
  end

  def calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
    cbm_ratio = trucking_pricing['cbm_ratio'] || 0
    quantity = cargo.try(:quantity) || 1
    volume = (cargo.try(:volume) || cargo[:volume])
    cbm_weight = volume * cbm_ratio * quantity
    raw_payload = (cargo.try(:payload_in_kg) || cargo[:payload_in_kg] || cargo.weight) * quantity
    trucking_chargeable_weight = [cbm_weight, raw_payload].max

    cargo_object['stackable']['weight'] += trucking_chargeable_weight
    cargo_object['stackable']['volume'] += volume * quantity
    cargo_object['stackable']['number_of_items'] += quantity
  end

  def calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
    cbm_ratio = trucking_pricing['cbm_ratio'] || 0
    cbm_weight = cargo.volume * cbm_ratio
    raw_payload = cargo.weight
    trucking_chargeable_weight = [cbm_weight, raw_payload].max

    cargo_object['stackable']['weight'] += trucking_chargeable_weight
    cargo_object['stackable']['volume'] += cargo.volume
    cargo_object['stackable']['number_of_items'] = 1
  end

  def round_fare(result, rounding_scope)
    if rounding_scope
      result.to_d.round(2)
    else
      result
    end
  end
end
