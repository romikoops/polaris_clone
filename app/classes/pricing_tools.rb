# frozen_string_literal: true

require 'bigdecimal'

module PricingTools # rubocop:disable Metrics/ModuleLength
  module_function

  include CurrencyTools
  DEFAULT_MAX = Float::INFINITY
  def get_user_price(pricing_id, shipment_date)
    pricing = Pricing.find(pricing_id)

    return if pricing.nil?

    pricing_exceptions = pricing
                         .pricing_exceptions
                         .where('effective_date <= ? AND expiration_date >= ?', shipment_date, shipment_date)
    pricing_details =
      if pricing_exceptions.any?
        pricing_exceptions.first.pricing_details
      else
        pricing.pricing_details
      end

    final_pricing = pricing_details.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }

    final_pricing.with_indifferent_access
  end

  def transport_category(cargo_unit, schedule)
    schedule.trip.tenant_vehicle.vehicle.transport_categories.find_by(
      name: 'any',
      cargo_class: cargo_unit.try(:size_class) || 'lcl',
      mode_of_transport: schedule.mode_of_transport
    )
  end

  def find_local_charge(schedule, cargos, direction, user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    hub = direction == 'export' ? schedule.origin_hub : schedule.destination_hub
    date = direction == 'export' ? schedule.etd : schedule.eta
    date = Date.today if date.nil?
    counterpart_hub_id = direction == 'export' ? schedule.destination_hub.id : schedule.origin_hub.id
    effective_local_charges = hub
                              .local_charges
                              .where(
                                direction: direction,
                                mode_of_transport: schedule.mode_of_transport,
                                tenant_vehicle_id: schedule.trip.tenant_vehicle_id
                              )
                              .for_dates(date, date)
    charges_for_filtering = []
    cargos.each do |cargo|
      load_type = cargo.is_a?(Container) ? cargo.size_class : 'lcl'
      [user.id, nil].each do |user_id|
        charge = effective_local_charges.find_by(
          user_id: user_id,
          load_type: load_type,
          counterpart_hub_id: counterpart_hub_id
        )
        charge ||= effective_local_charges.find_by(
          user_id: user_id,
          load_type: load_type,
          counterpart_hub_id: nil
        )
        charges_for_filtering << charge.as_json
      end
    end
    shipment_charges = {
      'load_type' => 'shipment',
      'fees' => {}
    }
    filtered_charges = charges_for_filtering.compact.map do |filter_charge|
      next if filter_charge['fees'].empty?

      filter_charge['fees'].each do |fk, fee|
        if %w(PER_SHIPMENT PER_BILL).include?(RateBasis.get_internal_key(fee['rate_basis']))
          shipment_charges['fees'][fk] = filter_charge['fees'].delete(fk)
        end
      end
      filter_charge
    end
    [filtered_charges.compact.uniq, shipment_charges]
  end

  def get_cargo_weight(cargo_unit)
    if cargo_unit.is_a?(CargoItem)
      cargo_unit.payload_in_kg * (cargo_unit.try(:quantity) || 1)
    elsif cargo_unit.is_a?(AggregatedCargo)
      cargo_unit.weight * (cargo_unit.try(:quantity) || 1)
    else
      cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
    end
  end

  def cargo_hash_for_local_charges(cargos, tenant) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if tenant.scope.dig('consolidation', 'cargo', 'backend')
      cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
        weight = get_cargo_weight(cargo_unit)

        return_h[:quantity] += cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
        return_h[:volume]   += (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0

        return_h[:weight]   += (cargo_unit.try(:weight) || weight)
      end
      [cargo_hash]
    else
      cargos.map do |cargo_unit|
        return_h = {}
        weight = get_cargo_weight(cargo_unit)

        return_h[:quantity] = cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
        return_h[:volume]   = (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0

        return_h[:weight]   = (cargo_unit.try(:weight) || weight)
        return_h[:id]       = cargo_unit.id
        return_h
      end
    end
  end

  def local_charge_calculation_block(charge_object, cargo_hash, user)
    totals = { 'total' => {} }

    charge_object.dig('fees')&.each do |k, fee|
      totals[k]             ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[k]['currency'] ||= fee['currency']
      totals[k]['value'] += fee_value(fee, cargo_hash, user.tenant.scope)
    end

    converted = sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    totals['total'] = { value: converted, currency: user.currency }
    totals['key'] = cargo_hash[:id] || charge_object['load_type']

    totals
  end

  def determine_local_charges(schedule, cargos, direction, user)
    unit_charges_array, shipment_charges = find_local_charge(schedule, cargos, direction, user)
    return {} if unit_charges_array.empty?

    null_cargo_hash = { weight: 0, volume: 0, quantity: 0 }
    charge_results = unit_charges_array.map do |charge_object|
      relevant_cargos = if %w(lcl shipment).include?(charge_object['load_type'])
                          cargos
                        else
                          cargos.select { |c| c.size_class == charge_object['load_type'] }
                        end
      cargo_hash_for_local_charges(relevant_cargos, user.tenant).map do |cargo_hash|
        local_charge_calculation_block(charge_object, cargo_hash, user)
      end
    end

    charge_results << local_charge_calculation_block(shipment_charges, null_cargo_hash, user)
    charge_results.flatten
  end

  def calc_customs_fees(charge, cargos, _load_type, user, mot)
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight = if cargo_unit.is_a?(CargoItem) || cargo_unit.is_a?(AggregatedCargo)
                 cargo_unit.calc_chargeable_weight(mot) * (cargo_unit.quantity || 1)
               else
                 cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
               end
      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.quantity.nil?
      return_h[:volume]          += (cargo_unit.try(:volume) || 1) * (cargo_unit.quantity || 1) || 0
      return_h[:weight]          += (cargo_unit.try(:weight) || weight)
    end

    return {} if charge.nil?

    totals = { 'total' => {} }
    charge.each do |k, fee|
      totals[k]             ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[k]['currency'] ||= fee['currency']

      totals[k]['value'] += fee_value(fee, cargo_hash, user.tenant.scope)
    end

    converted = sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    totals['total'] = { value: converted, currency: user.currency }
    totals
  end

  def calc_addon_charges(charge, cargos, user, mot)
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight = if cargo_unit.is_a?(CargoItem) || cargo_unit.is_a?(AggregatedCargo)
                 cargo_unit.calc_chargeable_weight(mot) * (cargo_unit.quantity || 1)
               else
                 cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
               end
      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.quantity.nil?
      return_h[:volume]          += cargo_unit.try(:volume) * (cargo_unit.quantity || 1) || 0
      return_h[:weight]          += (cargo_unit.try(:weight) || weight)
    end

    return {} if charge.nil?

    totals = { 'total' => {} }
    charge.each do |k, fee|
      totals[k] ||= { 'value' => 0, 'currency' => fee['currency'] }
      if !fee['unknown']
        totals[k]['currency'] ||= fee['currency']

        totals[k]['value'] += fee_value(fee, cargo_hash, user.tenant.scope)
      else
        totals[k]['value'] += 0
      end
    end

    converted = sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    totals['total'] = { value: converted, currency: user.currency }
    totals
  end

  def determine_cargo_item_price(cargo, pricing_id, user, _quantity, shipment_date, mot)
    return nil if pricing_id.nil?

    pricing = get_user_price(pricing_id, shipment_date)

    return nil if pricing.nil?

    totals = { 'total' => {} }

    pricing.keys.each do |k|
      fee = pricing[k].clone

      totals[k]             ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[k]['currency'] ||= fee['currency']

      totals[k]['value'] +=
        if fee['hw_rate_basis']
          heavy_weight_fee_value(fee, cargo, user.tenant.scope)
        else
          fee_value(fee, get_cargo_hash(cargo, mot), user.tenant.scope)
        end
    end

    converted = sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    cargo.try(:unit_price=, value: converted, currency: user.currency)
    totals['total'] = { value: converted, currency: user.currency }

    totals
  end

  def determine_container_price(container, pricing_id, user, _quantity, shipment_date, mot)
    return nil if pricing_id.nil?

    pricing = get_user_price(pricing_id, shipment_date)

    return nil if pricing.nil?

    totals = { 'total' => {} }

    pricing.each do |k, fee|
      totals[k]             ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[k]['currency'] ||= fee['currency']

      totals[k]['value'] += fee_value(fee, get_cargo_hash(container, mot), user.tenant.scope)
    end

    cargo_rate_value = sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    return if cargo_rate_value.nil? || cargo_rate_value.zero?

    container.unit_price = { value: cargo_rate_value, currency: user.currency }
    totals['total'] = { value: cargo_rate_value, currency: user.currency }
    totals
  end

  def get_tenant_pricings(tenant_id)
    Tenant.find(tenant_id).pricings.map(&:as_json)
  end

  def get_tenant_pricings_by_mot(tenant_id, mot)
    Tenant.find(tenant_id).itineraries.where(mode_of_transport: mot).flat_map { |it| it.pricings.map(&:as_json) }
  end

  def get_tenant_pricings_hash(tenant_id)
    pricings = get_tenant_pricings(tenant_id)
    pricings.each_with_object({}) do |pricing, return_h|
      return_h[pricing['id']] = pricing
    end
  end

  def get_itinerary_pricings_array(itinerary_id, tenant_id)
    itinerary = Itinerary.find_by(id: itinerary_id, tenant_id: tenant_id)
    itinerary.pricings.map(&:as_json)
  end

  def get_user_pricings(id)
    results = {}
    User.find(id).pricings.each do |pricing|
      unless results[pricing.itinerary_id]
        results[pricing.itinerary_id] = { itinerary: pricing.itinerary.as_options_json, pricings: [] }
      end
      results[pricing.itinerary_id][:pricings] << { pricing: pricing, transport_category: pricing.transport_category }
    end
    results
  end

  def get_itinerary_pricings(itinerary_id)
    Itinerary.find(itinerary_id).pricings.map(&:as_json)
  end

  def update_pricing(id, data)
    Pricing.find(id).update(data)
  end

  def get_itinerary_pricings_hash(itinerary_id)
    itinerary = Itinerary.find(itinerary_id)
    itinerary.pricings.each_with_object({}) do |pricing, return_h|
      pricing_key = "#{itinerary.first_stop.id}_#{itinerary.last_stop.id}_#{pricing.transport_category_id}"
      open = "#{pricing_key}_#{pricing.tenant_id}"
      return_h[pricing_key] = { id: pricing_key, open: open }
    end
  end

  def pricing_delete(id)
    Pricing.destroy(id)
  end

  def handle_range_fee(fee, cargo_hash) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    weight_kg = cargo_hash.fetch(:weight)
    volume = cargo_hash.fetch(:volume)
    min = fee['min'] || 0
    max = fee['max'] || DEFAULT_MAX
    rate_basis = RateBasis.get_internal_key(fee['rate_basis'])
    case rate_basis
    when 'PER_KG_RANGE'
      fee_range = fee['range'].find do |range|
        (range['min']..range['max']).cover?(weight_kg)
      end || fee['range'].max_by { |x| x['max'] }
      value = fee_range.nil? ? 0 : fee_range['rate'] * weight_kg

      res = [value, min].max
    when 'PER_UNIT_TON_CBM_RANGE'
      ratio = volume / (weight_kg / 1000)
      fee_range = fee['range'].find do |range|
        (range['min']..range['max']).cover?(ratio)
      end
      value = 0 if fee_range.nil?
      unless fee_range.nil?
        value = if fee['range'].index(fee_range).zero?
                  fee_range['rate'] * weight_kg / 1000
                else
                  fee_range['rate'] * volume
                end
      end
      res = [value, min].max

    when 'PER_CONTAINER_RANGE'
      value = 0 if fee_range.nil?
      unless fee_range.nil?
        fee_range = fee['range'].find do |range|
          (range['min']..range['max']).cover?(weight_kg)
        end
        value = fee_range['rate']
      end
      res = [value, min].max

    when 'PER_UNIT_RANGE'
      value = 0 if fee_range.nil?
      unless fee_range.nil?
        fee_range = fee['range'].find do |range|
          (range['min']..range['max']).cover?(weight_kg)
        end
        value = fee_range['rate']
      end
      res = [value, min].max

    end

    [res, max].min
  end

  def round_fee(result, should_round)
    if should_round
      result.to_d.round(2)
    else
      result
    end
  end

  def heavy_weight_fee_value(fee, cargo, scope)
    weight_kg = cargo.try(:weight) || cargo.try(:payload_in_kg)
    quantity  = cargo.try(:quantity) || 1
    cbm = cargo.volume
    ton = weight_kg / 1000

    result = if fee['hw_threshold']
               ratio = weight_kg / cbm

               if ratio > fee['hw_threshold']
                 rate_value = [cbm, ton].max * quantity * fee['rate'].to_i
                 [rate_value, fee['min']].max
               end

               0
             elsif fee['range']
               fee_range = fee['range'].find do |range|
                 weight_kg >= range['min'] && weight_kg <= range['max']
               end

               fee_range.nil? ? 0 : fee_range['rate'] * quantity
             end

    round_fee(result, scope['continuous_rounding'])
  end

  def fee_value(fee, cargo_hash, scope)
    rate_basis = RateBasis.get_internal_key(fee['rate_basis'])

    result = case rate_basis
             when 'PER_SHIPMENT', 'PER_BILL'
               (fee['value'] || fee['rate']).to_d
             when 'PER_ITEM', 'PER_CONTAINER'
               (fee['value'] || fee['rate']).to_d * cargo_hash[:quantity]
             when 'PER_CBM'
               min = fee['min'] || 0
               max = fee['max'] || DEFAULT_MAX
               val = fee['value'] || fee['rate']
               cbm = val.to_d * cargo_hash[:volume]
               res = [cbm, min].max
               [res, max].min
             when 'PER_KG'
               max = fee['max'] || DEFAULT_MAX
               val = fee['value'].to_d * cargo_hash[:weight]
               min = fee['min'] || 0
               res = [val, min].max
               [res, max].min
             when 'PER_X_KG_FLAT'
               max = fee['max'] || DEFAULT_MAX
               base = fee['base'].to_d
               val = fee['value'] * (cargo_hash[:weight].round(2) / base).ceil * base
               min = fee['min'] || 0
               res = [val, min].max
               [res, max].min
             when 'PER_CBM_TON'
               max = fee['max'] || DEFAULT_MAX
               cbm = cargo_hash[:volume] * fee['cbm']
               ton = (cargo_hash[:weight] / 1000) * fee['ton']
               min = fee['min'] || 0

               res = [cbm, ton, min].max
               [res, max].min
             when 'PER_TON'
               max = fee['max'] || DEFAULT_MAX
               ton = (cargo_hash[:weight] / 1000) * fee['ton']
               min = fee['min'] || 0
               res = [ton, min].max
               [res, max].min
             when 'PER_WM'
               max = fee['max'] || DEFAULT_MAX
               cbm = cargo_hash[:volume] * (fee['value'] || fee['rate'])
               ton = (cargo_hash[:weight] / 1000) * (fee['value'] || fee['rate'])
               min = fee['min'] || 0
               res = [cbm, ton, min].max

               [res, max].min
             when /RANGE/
               handle_range_fee(fee, cargo_hash)
             end

    round_fee(result, scope['continuous_rounding'])
  end

  def get_cargo_hash(cargo, mot)
    if cargo.is_a? Container
      {
        volume: (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight: (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
        quantity: cargo.try(:quantity) || 1
      }
    elsif cargo.is_a?(Hash)
      {
        volume: (cargo[:volume] || 1),
        weight: cargo[:chargeable_weight],
        quantity: cargo[:num_of_items]
      }
    else
      chargeable_weight = cargo.calc_chargeable_weight(mot)

      {
        volume: (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight: (cargo.try(:weight) || chargeable_weight) * (cargo.try(:quantity) || 1),
        quantity: cargo.try(:quantity) || 1
      }
    end
  end
end
