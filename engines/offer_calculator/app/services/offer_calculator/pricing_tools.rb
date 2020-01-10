# frozen_string_literal: true

require 'bigdecimal'

class OfferCalculator::PricingTools # rubocop:disable Metrics/ClassLength
  attr_accessor :scope, :user, :shipment
  def initialize(user:, shipment: nil, sandbox: nil)
    @user = user
    @shipment = shipment
    @scope = ::Tenants::ScopeService.new(
      target: ::Tenants::User.find_by(legacy_id: @user),
      tenant: ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    ).fetch
    @sandbox = sandbox
  end

  DEFAULT_MAX = Float::INFINITY

  def find_local_charge(schedules, cargos, direction, user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    hub = direction == 'export' ? schedules.first.origin_hub : schedules.last.destination_hub
    validity_service = OfferCalculator::ValidityService.new(
      logic: scope.fetch('validity_logic'),
      schedules: schedules,
      direction: direction,
      booking_date: shipment.desired_start_date
    )
    start_date = validity_service.start_date
    end_date = validity_service.end_date

    counterpart_hub_id = direction == 'export' ? schedules.last.destination_hub.id : schedules.first.origin_hub.id
    effective_local_charges = hub
                              .local_charges
                              .for_dates(start_date, end_date)
                              .where(
                                direction: direction,
                                mode_of_transport: schedules.first.mode_of_transport,
                                tenant_vehicle_id: schedules.first.trip.tenant_vehicle_id,
                                sandbox: @sandbox
                              )

    charges_for_filtering = []
    all_charges_with_metadata = []
    cargos.each do |cargo|
      load_type = cargo.is_a?(Legacy::Container) ? cargo.size_class : 'lcl'
      if @scope['base_pricing']
        group_ids = user.group_ids | [nil]
        group_ids.each do |group_id|
          charge = effective_local_charges.find_by(
            group_id: group_id,
            load_type: load_type,
            counterpart_hub_id: counterpart_hub_id
          )
          charge ||= effective_local_charges.find_by(
            group_id: group_id,
            load_type: load_type,
            counterpart_hub_id: nil
          )
          charges, local_charge_metadata =
            get_manipulated_local_charge(charge, cargos.first.shipment, schedules, cargo.id)

          if charges.present?
            charges.each do |charge|
              charges_for_filtering << charge
            end
          end

          all_charges_with_metadata |= local_charge_metadata if local_charge_metadata.present?
          break if charges.present?
        end
      else
        [user.pricing_id, nil].each do |user_pricing_id|
          charge = effective_local_charges.find_by(
            user_id: user_pricing_id,
            load_type: load_type,
            counterpart_hub_id: counterpart_hub_id
          )
          charge ||= effective_local_charges.find_by(
            user_id: user_pricing_id,
            load_type: load_type,
            counterpart_hub_id: nil
          )

          charges_for_filtering << charge&.as_json&.with_indifferent_access
          break if charge.present?
        end
      end
    end

    grouped_charges = charges_for_filtering.compact.group_by { |lc| lc.slice(:effective_date, :expiration_date) }

    local_charge_by_dates = grouped_charges.each_with_object({}) do |(dates, values), hash|
      shipment_charges = {
          'load_type' => 'shipment',
          'fees' => {},
          'flat_margins' => {}
        }.merge(values.first.slice(:effective_date, :expiration_date, :metadata_id))
      filtered_charges = values.compact.map do |filter_charge|

        next if filter_charge['fees'].empty?

        filter_charge['fees'].each do |fk, fee|
          if %w(PER_SHIPMENT PER_BILL PER_SHIPMENT_TON).include?(Legacy::RateBasis.get_internal_key(fee['rate_basis']))
            shipment_charges['fees'][fk] = filter_charge['fees'].delete(fk)
            shipment_charges['flat_margins'][fk] = filter_charge['flat_margins'].delete(fk) if filter_charge.dig(:charge, 'flat_margins', fk).present?
          end
        end
        filter_charge
      end
      results = [filtered_charges.compact.uniq]
      results << shipment_charges unless shipment_charges['fees'].empty?
      hash[dates] = results
    end
    [local_charge_by_dates, all_charges_with_metadata]
  end

  def get_cargo_weight(cargo_unit)
    if cargo_unit.is_a?(Legacy::CargoItem)
      cargo_unit.payload_in_kg * (cargo_unit.try(:quantity) || 1)
    elsif cargo_unit.is_a?(Legacy::AggregatedCargo)
      cargo_unit.weight * (cargo_unit.try(:quantity) || 1)
    else
      cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
    end
  end

  def consolidated_cargo_hash(cargos)
    cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight = get_cargo_weight(cargo_unit)

      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
      return_h[:volume]   += (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0

      return_h[:weight]   += (cargo_unit.try(:weight) || weight)
    end
  end

  def cargo_hash_for_local_charges(cargos, consolidated_hash, consolidation) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if consolidation.dig('cargo', 'backend')
      [consolidated_hash]
    else
      cargos.map do |cargo_unit|
        return_h = {}
        weight = get_cargo_weight(cargo_unit)

        return_h[:quantity] = cargo_unit.try(:quantity).nil? ? 1 : cargo_unit.quantity
        return_h[:volume]   = (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0

        return_h[:weight]   = (cargo_unit.try(:weight) || weight)
        return_h[:id]       = cargo_unit.id
        return_h
      end
    end
  end

  def local_charge_calculation_block(charge_object, cargo_hash,  user)
    totals = { 'total' => {} }
    charge_object.fetch('fees', {}).each do |key, fee|
      totals[key]             ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[key]['currency'] ||= fee['currency']
      totals[key]['value'] +=
        fee_value(
          fee: fee,
          cargo: cargo_hash,
          rounding: @scope.fetch(:continuous_rounding)
        )

      totals[key]['value'] += charge_object.dig('flat_margins', key) if charge_object.dig('flat_margins', key).present?
    end

    converted = Legacy::CurrencyTools.new.sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    totals['total'] = { value: converted, currency: user.currency }
    totals['key'] = cargo_hash.has_key?(:id) ?cargo_hash[:id] : charge_object['load_type']
    totals['metadata_id'] = charge_object['metadata_id']

    totals
  end

  def determine_local_charges(schedules, cargos, direction, user) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    charges_by_dates, local_charge_metadata = find_local_charge(schedules, cargos, direction, user)
    return {} if charges_by_dates.empty?

    consolidated_hash = consolidated_cargo_hash(cargos)
    result = charges_by_dates.each_with_object({}) do |(dates, values), hash|
      unit_charges_array, shipment_charges = values
      hash[dates] = {} if unit_charges_array.empty?
      next if unit_charges_array.empty?

      null_cargo_hash = { weight: 0, volume: 0, quantity: 0 }
      charge_results = unit_charges_array.map do |charge_object|
        next if charge_object['fees'].empty?

        relevant_cargos = if %w(lcl shipment).include?(charge_object['load_type'])
                            cargos
                          else
                            cargos.select { |c| c.size_class == charge_object['load_type'] }
                          end
        cargo_hashes = cargo_hash_for_local_charges(relevant_cargos, consolidated_hash, @scope.fetch(:consolidation))
        cargo_hashes.map do |cargo_hash|
          local_charge_calculation_block(
                      charge_object,
                      cargo_hash,
                      user
                    )
        end
      end
      if shipment_charges
        charge_results << local_charge_calculation_block(
            shipment_charges,
            consolidated_hash,
            user
          )
      end
      hash[dates] = charge_results.flatten.compact
    end
    [ result, local_charge_metadata ]
  end

  def calc_addon_charges(charge:, cargos:, user:, mode_of_transport:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      quantity = cargo_unit.try(:quantity) || 1
      weight = if cargo_unit.is_a?(Legacy::CargoItem) || cargo_unit.is_a?(Legacy::AggregatedCargo)
                 cargo_unit.calc_chargeable_weight(mode_of_transport) * quantity
               else
                 cargo_unit.payload_in_kg * quantity
               end
      return_h[:quantity] += quantity unless quantity.nil?
      return_h[:volume]   += (cargo_unit.try(:volume) || 0) * quantity
      return_h[:weight]   += (cargo_unit.try(:weight) || weight)
    end

    return {} if charge.nil?

    totals = { 'total' => {} }
    charge.each do |k, fee|
      totals[k] ||= { 'value' => 0, 'currency' => fee['currency'] }
      if !fee['unknown']
        totals[k]['currency'] ||= fee['currency']

        totals[k]['value'] += fee_value(
          fee: fee,
          cargo: cargo_hash,
          rounding: @scope.fetch(:continuous_rounding)
        )
      else
        totals[k]['value'] += 0
      end
    end

    converted = Legacy::CurrencyTools.new.sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    totals['total'] = { 'value' => converted, 'currency' => user.currency }
    totals
  end

  def determine_cargo_freight_price(cargo:, pricing:, user:, mode_of_transport:) # rubocop:disable Metrics/ParameterLists, Metrics/AbcSize
    return nil if pricing.nil?

    totals = Hash.new{|h, k| h[k] = { 'value' => 0, 'currency' => '' } }

    pricing.keys.each do |k|
      fee = pricing[k].clone

      totals[k]['currency'] = fee['currency']

      totals[k]['value'] +=
        if fee['hw_rate_basis']
          heavy_weight_fee_value(fee, cargo, @scope.fetch(:continuous_rounding))
        else
          fee_value(
            fee: fee,
            cargo: get_cargo_hash(cargo, mode_of_transport),
            rounding: @scope.fetch(:continuous_rounding)
          )
        end
    end

    converted = Legacy::CurrencyTools.new.sum_and_convert_cargo(totals, user.currency, user.tenant_id)
    cargo.try(:unit_price=, value: converted, currency: user.currency)
    totals['total'] = { 'value' => converted, 'currency' => user.currency }

    totals
  end

  def handle_range_fee(fee, cargo_hash) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    weight_kg = cargo_hash.fetch(:weight)
    volume = cargo_hash.fetch(:volume)
    quantity = cargo_hash.fetch(:quantity, 1)
    min = (fee['min'] || 0).to_d
    max = (fee['max'] || DEFAULT_MAX).to_d
    rate_basis = Legacy::RateBasis.get_internal_key(fee['rate_basis'])

    result = case rate_basis
             when 'PER_KG_RANGE'
               fee_range = fee['range'].find do |range|
                 (range['min']..range['max']).cover?(weight_kg)
               end
               fee_range ||= fee['range'].max_by { |x| x['max'] }
               fee_range.nil? ? 0 : fee_range['rate'].to_d * weight_kg
             when 'PER_CBM_RANGE'
               fee_range = fee['range'].find do |range|
                 (range['min']..range['max']).cover?(volume)
               end
               fee_range ||= fee['range'].max_by { |x| x['max'] }
               fee_range.nil? ? 0 : fee_range['rate'] * (weight_kg / 1000.to_d)
             when 'PER_UNIT_TON_CBM_RANGE'
               ratio = volume / (weight_kg / 1000.to_d)
               fee_range = fee['range'].find do |range|
                 (range['min']..range['max']).cover?(ratio)
               end
               fee_range ||= fee['range'].max_by { |x| x['max'] }

               if fee_range['ton']
                 fee_range['ton'].to_d * (weight_kg / 1000.to_d)
               elsif fee_range['cbm']
                 fee_range['cbm'].to_d * volume
               end
             when 'PER_UNIT_RANGE'
               fee_range = fee['range'].find do |range|
                 (range['min']..range['max']).cover?(quantity)
               end
               fee_range ||= fee['range'].max_by { |x| x['max'] }

               fee_range.nil? ? 0 : fee_range['rate'].to_d
            end

    [result, max].min
  end

  def round_fee(result, should_round)
    if should_round
      result.to_d.round(2)
    else
      result
    end
  end

  def heavy_weight_fee_value(fee, cargo, continuous_rounding) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    weight_kg = cargo.try(:weight) || cargo.try(:payload_in_kg)
    quantity  = cargo.try(:quantity) || 1
    cbm = cargo.volume
    ton = weight_kg / 1000.to_d
    min = fee['min'] || 0

    result = if fee['hw_threshold']
               ratio = weight_kg / cbm
               if ratio > fee['hw_threshold']
                 rate_value = [cbm, ton].max * quantity * fee['rate'].to_i
                 [rate_value, min].max
               else
                 0
               end
             elsif fee['range']
               max_fee = fee['range'].max_by { |x| x['max'] }
               fee_range = max_fee if weight_kg > max_fee['max']

               fee_range ||= fee['range'].find do |range|
                 (range['min']..range['max']).cover?(weight_kg)
               end

               fee_range.nil? ? 0 : fee_range['rate'] * quantity
             end

    round_fee(result, continuous_rounding)
  end

  def fee_value(fee:, cargo:, rounding: false) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    rate_basis = Legacy::RateBasis.get_internal_key(fee['rate_basis'])
    value = (fee['value'] || fee['rate'] || 0).to_d
    max = (fee['max'] || DEFAULT_MAX).to_d
    min = (fee['min'] || 0).to_d

    result = case rate_basis
             when 'PER_SHIPMENT', 'PER_BILL'
               value
             when 'PER_ITEM', 'PER_CONTAINER'
               value * cargo[:quantity]
             when 'PER_CBM'
               value * cargo[:volume]
             when 'PER_KG'
               value * cargo[:weight]
             when 'PER_X_KG_FLAT'
               base = fee['base'].to_d
               value * (cargo[:weight].round(2) / base).ceil * base
             when 'PER_CBM_TON'
               cbm = cargo[:volume] * fee['cbm'].to_d
               tonne = (cargo[:weight] / 1000.to_d) * fee['ton'].to_d
               [cbm, tonne].max
             when 'PER_TON'
               (cargo[:weight] / 1000.to_d) * (fee['ton'] || value).to_d
             when 'PER_SHIPMENT_TON'
               (cargo[:weight] / 1000.to_d) * value
             when 'PER_WM'
               cbm = cargo[:volume] * value
               tonne = (cargo[:weight] / 1000.to_d) * value
               [cbm, tonne].max
             when /RANGE/
               handle_range_fee(fee, cargo)
             end

    round_fee(result.clamp(min, max), rounding)
  end

  def get_cargo_hash(cargo, mot)
    if cargo.is_a? Legacy::Container
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

  def get_manipulated_local_charge(local_charge, shipment, schedules, cargo_unit_id)
    return nil if local_charge.nil?

    Pricings::Manipulator.new(
      type: "#{local_charge.direction}_margin".to_sym,
      user: ::Tenants::User.find_by(legacy_id: shipment.user_id),
      args: {
        cargo_class: local_charge.load_type,
        schedules: schedules,
        shipment: shipment,
        local_charge: local_charge,
        sandbox: @sandbox,
        cargo_unit_id: cargo_unit_id
      }
    ).perform
  end
end
