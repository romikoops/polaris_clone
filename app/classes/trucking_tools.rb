# frozen_string_literal: true

require 'bigdecimal'

module TruckingTools
  module_function

  LoadMeterageExceeded = Class.new(StandardError)

  LOAD_METERAGE_AREA_DIVISOR = 24_000
  CBM_VOLUME_DIVISOR = 1_000_000
  DEFAULT_MAX = 1_000_000
  TRUCKING_CONTAINER_HEIGHT = 260

  def calculate_trucking_price(pricing, cargo, _direction, kms, scope)
    fees = {}
    result = {}
    total_fees = {}
    return {} if pricing.empty?

    pricing.deep_symbolize_keys!
    pricing[:fees].each do |k, fee|
      if fee[:rate_basis] != 'PERCENTAGE'
        results = fare_calculator(k, fee, cargo, kms, scope)
        fees[k] = results
      else
        total_fees[k] = fee
      end
    end
    fees[:rate] = fare_calculator('rate', pricing[:rate], cargo, kms, scope)

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

  def fare_calculator(key, fee, cargo, kms, scope)
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
             val = ((kms / fee[:x_base]) * fee[:rate]) + fee[:base_value]
             min = fee[:min_value] || 0
             [val, min].max
           when 'PER_X_TON'
             val = ((cargo['weight'] / 1000) / fee[:base]) * fee[:value]
             min = fee[:min_value] || 0
             [val, min].max
           when 'PER_SHIPMENT'
             fee.except(:rate_basis, :currency, :base).values.max
           when 'PER_BILL'
             fee[:value]
           when 'PER_ITEM'
             fee[:value] * cargo['number_of_items']
           when 'PER_CONTAINER'
             fee[:value] * cargo['number_of_items']
           when 'PER_CONTAINER_KM'
             value = ((fee[:km] * kms) + fee[:unit]) * cargo['number_of_items']
             min = fee[:min_value] || 0
             [min, value].max

           when 'PER_CBM_TON'
             cbm_value = cargo['volume'] * fee[:cbm]
             ton_value = (cargo['weight'] / 1000) * fee[:ton]
             min = fee[:min_value] || 0
             [ton_value, cbm_value, min].max
           when 'PER_KG_CBM_SPECIAL'
             kg_sub = fee.dig(:kg_sub, :rate, :value).to_d
             kg_base = fee.dig(:kg_base, :rate, :value).to_d
             kg_factor = fee.dig(:kg, :rate, :value).to_d
             kg_min = fee.dig(:kg, :min_value).to_d
             kg_value = ((cargo['weight'] - kg_sub) * kg_factor) + kg_base
             cbm_sub = fee.dig(:cbm_sub, :rate, :value).to_d
             cbm_base = fee.dig(:cbm_base, :rate, :value).to_d
             cbm_factor = fee.dig(:cbm, :rate, :value).to_d
             cbm_value = ((cargo['volume'] - cbm_sub) * cbm_factor) + cbm_base
             cbm_min = fee.dig(:cbm, :min_value).to_d

             [kg_value, cbm_value, cbm_min, kg_min].max
           when 'PER_CBM'
             cbm_value = cargo['volume'] * (fee[:value] || fee[:cbm])
             min = fee[:min_value] || 0
             [cbm_value, min].max

           when 'PER_WM'
             wm = [cargo['weight'] / 1000, cargo['volume']].max
             value = wm * fee[:value]
             min = fee[:min_value] || 0
             [value, min].max

           when 'PER_CBM_KG'
             cbm_value = cargo['volume'] * fee[:cbm]
             kg_value = cargo['weight'] * fee[:kg]
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

  def filter_trucking_pricings(trucking_pricing, cargo_values, scope)
    return {} if cargo_values['weight'].to_i.zero?

    case trucking_pricing.modifier
    when 'kg'
      if cargo_values['weight'].to_i > trucking_pricing['rates']['kg'].compact.last['max_kg'].to_i && scope['hard_trucking_limit']
        raise TruckingTools::LoadMeterageExceeded
      elsif cargo_values['weight'].to_i > trucking_pricing['rates']['kg'].compact.last['max_kg'].to_i && !scope['hard_trucking_limit']
        rate = trucking_pricing['rates']['kg'].compact.last
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
      result = {}
      trucking_pricing['rates']['kg'].each do |rate|
        next unless cargo_values['weight'].to_i <= rate['max_kg'].to_i && cargo_values['weight'].to_i >= rate['min_kg'].to_i

        result['kg'] = rate['rate']['value']
        result['rate_basis'] = rate['rate']['rate_basis']
        result['min_value'] = rate['min_value']
        result['currency'] = rate['rate']['currency']
      end
      trucking_pricing['rates']['cbm'].each do |rate|
        next unless cargo_values['volume'] <= rate['max_cbm'].to_i && cargo_values['volume'] >= rate['min_cbm'].to_i

        result['rate_basis'] = rate['rate']['rate_basis']
        result['cbm'] = rate['rate']['value']
        result['min_value'] = rate['min_value']
        result['currency'] = rate['rate']['currency']
      end
      if cargo_values['volume'] < trucking_pricing['rates']['cbm'].first['min_cbm'].to_i
        result['rate_basis'] = trucking_pricing['rates']['cbm'].first['rate']['rate_basis']
        result['cbm'] = trucking_pricing['rates']['cbm'].first['rate']['value']
        result['min_value'] = trucking_pricing['rates']['cbm'].first['min_value']
        result['currency'] = trucking_pricing['rates']['cbm'].first['rate']['currency']
      elsif cargo_values['volume'] > trucking_pricing['rates']['cbm'].compact.last['max_cbm'].to_i
        result['rate_basis'] = trucking_pricing['rates']['cbm'].compact.last['rate']['rate_basis']
        result['cbm'] = trucking_pricing['rates']['cbm'].compact.last['rate']['value']
        result['min_value'] = trucking_pricing['rates']['cbm'].compact.last['min_value']
        result['currency'] = trucking_pricing['rates']['cbm'].compact.last['rate']['currency']
      end
      return { rate: result, fees: trucking_pricing['fees'] }
    when 'unit'
      return { rate: trucking_pricing['rates']['unit'][0]['rate'], fees: trucking_pricing['fees'] }
    when 'kg_cbm_special'
      result = { rate_basis: 'PER_KG_CBM_SPECIAL' }
      %w(kg	kg_base	kg_sub cbm cbm_base cbm_sub).each do |sym|
        result[sym] = trucking_pricing['rates'][sym].first
      end

      result['currency'] = trucking_pricing['rates']['kg'].first['rate']['currency']
      return { rate: result, fees: trucking_pricing['fees'] }
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
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }, 'non_stackable' => {
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }
    }
    consolidation = ::Tenants::ScopeService.new(user: cargos.first.shipment.user).fetch(:consolidation)
    if consolidation.dig('trucking', 'load_meterage_only')
      consolidated_load_meterage(trucking_pricing, cargo_object, cargos)
    elsif consolidation.dig('trucking', 'comparative')
      comparative_load_meterage(trucking_pricing, cargo_object, cargos)
    elsif consolidation.dig('trucking', 'calculation')
      consolidated_trucking_cargo(trucking_pricing, cargo_object, cargos)
    else
      cargos.each do |cargo|
        determine_load_meterage(trucking_pricing, cargo_object, cargo)
      end
    end

    target = "#{trucking_pricing.carriage || trucking_pricing.scope.carriage}_carriage"
    total_chargeable_weight =
      cargo_object.dig('stackable', 'weight') + cargo_object.dig('non_stackable', 'weight')
    cargos.first.shipment.set_trucking_chargeable_weight(target, total_chargeable_weight)

    cargo_object
  end

  def consolidated_trucking_cargo(trucking_pricing, cargo_object, cargos)
    cargo = if cargos.first.is_a? AggregatedCargo
              cargos.first
            else
              consolidate_cargo(cargos)
            end
    determine_load_meterage(trucking_pricing, cargo_object, cargo)
  end

  def consolidate_cargo(cargo_array)
    cargo = {
      id: 'ids',
      dimension_x: 0,
      dimension_y: 0,
      dimension_z: 0,
      volume: 0,
      payload_in_kg: 0,
      cargo_class: '',
      num_of_items: 0,
      quantity: 1
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
      cargo[:stackable] = true
    end

    cargo
  end

  def consolidated_load_meterage(trucking_pricing, cargo_object, cargos)
    if cargos.first.is_a? AggregatedCargo
      total_area =  cargos.first.volume / 1.3
      non_stackable = false
    else
      total_area =  cargos.sum { |cargo| cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo) * cargo.quantity }
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

  def comparative_load_meterage(trucking_pricing, cargo_object, cargos)
    total_load_meterage_weight = 0.0
    total_cbm_weight = 0.0
    total_payload_weight = 0.0
    total_area = 0.0
    shipment = cargos.first.shipment
    cargos.each do |cargo|
      trucking_weight = if cargo.stackable
                          trucking_chargeable_weight_by_stacked_area(trucking_pricing, cargo)
                        else
                          trucking_chargeable_weight_by_area(trucking_pricing, cargo)
                        end
      total_load_meterage_weight += trucking_weight
      total_cbm_weight += trucking_cbm_weight(trucking_pricing, cargo)
      total_payload_weight += trucking_payload_weight(cargo)
      total_area += trucking_payload_area(cargo)
    end

    total_load_meters = total_load_meterage_weight / trucking_pricing.load_meterage['ratio']
    if total_load_meters >= (trucking_pricing.load_meterage['ldm_limit'] || DEFAULT_MAX)
      effective_weight = [total_load_meterage_weight, total_cbm_weight, total_payload_weight].max
      stackable_key = effective_weight == total_load_meterage_weight ? 'non_stackable' : 'stackable'

    else
      effective_weight = [total_cbm_weight, total_payload_weight].max
      stackable_key = 'stackable'
    end
    key = case effective_weight
          when total_load_meterage_weight
            'ldm'
          when total_cbm_weight
            'cbm'
          when total_payload_weight
            'kg'
          end
    shipment.meta["trucking_#{trucking_pricing.carriage}"] ||= {}
    shipment.meta["trucking_#{trucking_pricing.carriage}"][trucking_pricing.hub_id] = { trigger: key, value: effective_weight }
    cargo_object[stackable_key]['weight'] += effective_weight
    cargo_object[stackable_key]['volume'] += cargos_volume(cargos)
    cargo_object[stackable_key]['number_of_items'] += cargos.map(&:quantity).sum
  end

  def get_container_object(containers)
    containers.each_with_object({}) do |cargo, cargo_object|
      cargo_object["container_#{cargo.id}"] = {
        'weight' => cargo.payload_in_kg,
        'number_of_items' => cargo.quantity
      }
    end
  end

  def calc_trucking_price(trucking_pricing, cargos, kms, carriage, shipment)
    user = shipment.user
    direction = carriage == 'pre' ? 'export' : 'import'
    cargo_object = if trucking_pricing.load_type == 'container'
                     get_container_object(cargos)
                   else
                     get_cargo_item_object(trucking_pricing, cargos)
                   end

    trucking_pricings = {}
    scope = ::Tenants::ScopeService.new(user: user).fetch
    return {} if trucking_pricing.rates.empty?

    cargo_object.each do |stackable_type, cargo_values|
      trucking_pricings[stackable_type] = filter_trucking_pricings(trucking_pricing, cargo_values, scope)
    end

    fees = {}
    trucking_pricings.each do |key, tp|
      fees[key] = calculate_trucking_price(tp, cargo_object[key], direction, kms, scope) if tp
    end

    total = { value: 0, currency: '' }
    fees.each do |_key, trucking_fee|
      next if trucking_fee.empty?

      total[:value] += trucking_fee[:value]
      total[:currency] = trucking_fee[:currency]
    end

    total[:currency] = trucking_pricing.tenant.currency if total[:currency] == '' && total[:value].zero?

    fees[:total] = total
    fees
  end

  def determine_load_meterage(trucking_pricing, cargo_object, cargo)
    if trucking_pricing.load_meterage && trucking_pricing.load_meterage['ratio']
      if cargo.is_a? AggregatedCargo
        calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      else
        if (trucking_pricing.load_meterage['height_limit'] &&
          (cargo[:dimension_z] > trucking_pricing.load_meterage['height_limit'])) ||
           (!cargo[:stackable] && trucking_pricing.load_meterage['height_limit'])
          calc_cargo_load_meterage_height(trucking_pricing, cargo_object, cargo)
        elsif (trucking_pricing.load_meterage['area_limit'] &&
          ((cargo[:dimension_x] * cargo[:dimension_y] * cargo[:quantity]) >= trucking_pricing.load_meterage['area_limit'])) ||
              (!cargo[:stackable] && trucking_pricing.load_meterage['area_limit'])
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
    volume = cargo_volume(cargo)
    load_meterage = (volume / 1.3) / 2.4
    load_meter_weight = load_meterage * trucking_pricing.load_meterage['ratio']
    trucking_chargeable_weight = load_meter_weight > cargo.weight ? load_meter_weight : cargo.weight
    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += volume

    cargo_object
  end

  def calc_cargo_load_meterage_height(trucking_pricing, cargo_object, cargo)
    load_meter_weight = trucking_chargeable_weight_by_height(trucking_pricing, cargo)
    cbm_weight = trucking_cbm_weight(trucking_pricing, cargo)
    raw_payload = trucking_payload_weight(cargo)

    trucking_chargeable_weight = [load_meter_weight, raw_payload, cbm_weight].max
    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += cargo_volume(cargo) * cargo_quantity(cargo)
    cargo_object['non_stackable']['number_of_items'] += cargo_quantity(cargo)

    cargo_object
  end

  def calc_cargo_load_meterage_area(trucking_pricing, cargo_object, cargo)
    load_meter_weight = trucking_chargeable_weight_by_area(trucking_pricing, cargo)
    cbm_weight = trucking_cbm_weight(trucking_pricing, cargo)
    raw_payload = trucking_payload_weight(cargo)
    trucking_chargeable_weight = [load_meter_weight, raw_payload, cbm_weight].max

    cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
    cargo_object['non_stackable']['volume'] += cargo_volume(cargo) * cargo_quantity(cargo)
    cargo_object['non_stackable']['number_of_items'] += cargo_quantity(cargo)

    cargo_object
  end

  def calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
    cbm_weight = trucking_cbm_weight(trucking_pricing, cargo)
    raw_payload = trucking_payload_weight(cargo)
    trucking_chargeable_weight = [cbm_weight, raw_payload].max

    cargo_object['stackable']['weight'] += trucking_chargeable_weight
    cargo_object['stackable']['volume'] += cargo_volume(cargo)
    cargo_object['stackable']['number_of_items'] += cargo_quantity(cargo)

    cargo_object
  end

  def calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
    cbm_weight = trucking_cbm_weight(trucking_pricing, cargo)
    raw_payload = cargo.weight
    trucking_chargeable_weight = [cbm_weight, raw_payload].max

    cargo_object['stackable']['weight'] += trucking_chargeable_weight
    cargo_object['stackable']['volume'] += cargo_volume(cargo)
    cargo_object['stackable']['number_of_items'] = 1

    cargo_object
  end

  def cargo_data_value(dim, cargo)
    cargo.try(dim.to_sym) || cargo[dim.to_sym]
  end

  def trucking_chargeable_weight_by_area(trucking_pricing, cargo)
    area_var = cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo) * cargo_quantity(cargo)
    load_meter_var = area_var / LOAD_METERAGE_AREA_DIVISOR
    load_meter_var * trucking_pricing.load_meterage['ratio']
  end

  def trucking_chargeable_weight_by_height(trucking_pricing, cargo)
    load_meterage = (
        (cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo)) / LOAD_METERAGE_AREA_DIVISOR
      ) * cargo_quantity(cargo)
    load_meterage * trucking_pricing.load_meterage['ratio']
  end

  def trucking_chargeable_weight_by_stacked_area(trucking_pricing, cargo)
    stack_height = TRUCKING_CONTAINER_HEIGHT / cargo_data_value(:dimension_z, cargo).floor
    num_stacks = (cargo_quantity(cargo) / stack_height.to_d).ceil
    stacked_area = cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo) * num_stacks
    load_meter_var = stacked_area / LOAD_METERAGE_AREA_DIVISOR
    load_meter_var * trucking_pricing.load_meterage['ratio']
  end

  def trucking_cbm_weight(trucking_pricing, cargo)
    cbm_ratio = trucking_pricing['cbm_ratio'] || 0
    volume = cargo_volume(cargo)
    volume * cbm_ratio
  end

  def cargo_volume(cargo)
    if cargo.is_a?(AggregatedCargo)
      cargo.volume
    else
      cargo_unit_volume(cargo) * cargo_quantity(cargo)
    end
  end

  def cargo_unit_volume(cargo)
    if cargo.is_a?(AggregatedCargo)
      cargo.volume
    elsif cargo.is_a?(Hash)
      cargo[:volume]
    else
      (cargo[:dimension_x] * cargo[:dimension_y] * cargo[:dimension_z]) / CBM_VOLUME_DIVISOR
    end
  end

  def cargo_quantity(cargo)
    if cargo.is_a?(AggregatedCargo)
      1
    elsif cargo.is_a?(Hash)
      cargo[:quantity] || 1
    else
      cargo.quantity
    end
  end

  def cargos_volume(cargos)
    cargos.map { |cargo| cargo_volume(cargo) }.sum
  end

  def trucking_payload_weight(cargo)
    quantity = cargo.try(:quantity) || 1
    (cargo.try(:payload_in_kg) || cargo[:payload_in_kg] || cargo.weight) * quantity
  end

  def trucking_payload_area(cargo)
    quantity = cargo.try(:quantity) || 1
    (cargo.try(:dimension_x) || cargo[:dimension_x]) * (cargo.try(:dimension_y) || cargo[:dimension_y]) * quantity
  end

  def round_fare(result, rounding_scope)
    if rounding_scope
      result.to_d.round(2)
    else
      result
    end
  end
end
