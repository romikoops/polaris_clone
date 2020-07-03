# frozen_string_literal: true

require 'bigdecimal'

class OfferCalculator::PricingTools # rubocop:disable Metrics/ClassLength
  attr_accessor :scope, :user, :shipment, :metadata

  def initialize(user:, shipment: nil, sandbox: nil, metadata: [])
    @user = user
    @shipment = shipment
    @target = @user
    @organization = ::Organizations::Organization.find(shipment.organization_id)
    @target ||= Groups::Group.find_by(name: 'default', organization_id: shipment.organization_id)
    @scope = ::OrganizationManager::ScopeService.new(
      target: @target,
      organization: @organization
    )
    @sandbox = sandbox
    @metadata = metadata
    @currency = Users::Settings.find_by(user: user)&.currency || @scope.fetch(:default_currency)
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
    cargos_for_loop(cargos: cargos).each do |cargo_data|
      group_ids = user_groups.pluck(:group_id) | [nil]
      group_ids.each do |group_id|
        charge = effective_local_charges.find_by(
          group_id: group_id,
          load_type: cargo_data[:load_type],
          counterpart_hub_id: counterpart_hub_id
        )
        charge ||= effective_local_charges.find_by(
          group_id: group_id,
          load_type: cargo_data[:load_type],
          counterpart_hub_id: nil
        )
        charges, local_charge_metadata =
          get_manipulated_local_charge(charge, @shipment, schedules, cargo_data[:cargo_id])

        if charges.present?
          charges.each do |charge_result|
            charges_for_filtering << charge_result
          end
        end

        @metadata |= local_charge_metadata if local_charge_metadata.present?
        break if charges.present?
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
          unless %w[PER_SHIPMENT PER_BILL PER_SHIPMENT_TON].include?(Legacy::RateBasis.get_internal_key(fee['rate_basis']))
            next
          end

          shipment_charges['fees'][fk] = filter_charge['fees'].delete(fk)
          if filter_charge.dig('flat_margins', fk).present?
            shipment_charges['flat_margins'][fk] = filter_charge['flat_margins'].delete(fk)
          end
        end
        filter_charge
      end
      results = [filtered_charges.compact.uniq]
      results << shipment_charges unless shipment_charges['fees'].empty?
      hash[dates] = results
    end
    local_charge_by_dates
  end

  def get_cargo_weights(cargo:, mot:)
    if cargo.is_a?(Legacy::CargoItem)
      [
        cargo.payload_in_kg * (cargo.try(:quantity) || 1),
        cargo.calc_chargeable_weight(mot) * (cargo.try(:quantity) || 1)
      ]
    elsif cargo.is_a?(Legacy::AggregatedCargo)
      [
        cargo.weight * (cargo.try(:quantity) || 1),
        cargo.calc_chargeable_weight(mot) * (cargo.try(:quantity) || 1)
      ]
    else
      [
        cargo.payload_in_kg * (cargo.quantity || 1),
        cargo.payload_in_kg * (cargo.quantity || 1)
      ]
    end
  end

  def consolidated_cargo_hash(cargos:, mot:)
    cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight, chargeable_weight = get_cargo_weights(cargo: cargo_unit, mot: mot)

      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
      return_h[:volume]   += (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0
      return_h[:weight_measure] = chargeable_weight / 1000.0
      return_h[:weight] += (cargo_unit.try(:weight) || weight)
      return_h[:raw_weight] += (cargo_unit.try(:weight) || weight)
      return_h[:weight_measure] += (cargo_unit.try(:weight) || weight)
    end
  end

  def cargo_hash_for_local_charges(cargos:, mot:) # rubocop:disable Metrics/CyclomaticComplexity
    cargos.map do |cargo_unit|
      return_h = {}
      weight, chargeable_weight = get_cargo_weights(cargo: cargo_unit, mot: mot)

      return_h[:quantity] = cargo_unit.try(:quantity).nil? ? 1 : cargo_unit.quantity
      return_h[:volume]   = (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity) || 1) || 0

      return_h[:weight_measure] = chargeable_weight / 1000.0
      return_h[:weight] = (cargo_unit.try(:weight) || weight)
      return_h[:raw_weight] = (cargo_unit.try(:weight) || weight)
      return_h[:id] = cargo_unit.id
      return_h
    end
  end

  def local_charge_calculation_block(charge_object, cargo_hash, user)
    totals = { 'total' => {} }
    charge_object.fetch('fees', {}).each do |key, fee|
      fee[:key] = key
      calculated_value = fee_value(
        fee: fee,
        cargo: cargo_hash,
        rounding: @scope.fetch(:continuous_rounding),
        metadata_id: charge_object[:metadata_id]
      )

      next if calculated_value.blank?

      totals[key] ||= { 'value' => 0, 'currency' => fee['currency'] }
      totals[key]['currency'] ||= fee['currency']
      totals[key]['value'] += calculated_value

      totals[key]['value'] += charge_object.dig('flat_margins', key) if charge_object.dig('flat_margins', key).present?
    end

    converted = ::Legacy::ExchangeHelper.sum_and_convert_cargo(totals, @currency)
    return nil if converted.zero?

    totals['total'] = { value: converted.cents / 100.0, currency: converted.currency }
    totals['key'] = cargo_hash.key?(:id) ? cargo_hash[:id] : charge_object['load_type']
    totals['metadata_id'] = charge_object['metadata_id']

    totals
  end

  def determine_local_charges(schedules, cargos, direction, user) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    charges_by_dates = find_local_charge(schedules, cargos, direction, user)
    return {} if charges_by_dates.empty?

    consolidated_hash = consolidated_cargo_hash(cargos: cargos, mot: schedules.first.mode_of_transport)

    result = charges_by_dates.each_with_object({}) do |(dates, values), hash|
      unit_charges_array, shipment_charges = values
      hash[dates] = {} if unit_charges_array.empty?
      next if unit_charges_array.empty?

      charge_results = unit_charges_array.map do |charge_object|
        next if charge_object['fees'].empty?

        relevant_cargos = if %w[lcl shipment].include?(charge_object['load_type'])
                            cargos
                          else
                            cargos.select { |c| c.size_class == charge_object['load_type'] }
                          end
        cargo_hashes = if @scope.fetch(:consolidation, :cargo, :backend)
                         [consolidated_hash]
                       else
                         cargo_hash_for_local_charges(
                           cargos: relevant_cargos,
                           mot: schedules.first.mode_of_transport
                         )
          end
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
    [result, metadata]
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
      fee['key'] = k
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

    currency = Users::Settings.find_by(user: user).currency
    converted = ::Legacy::ExchangeHelper.sum_and_convert_cargo(totals, currency)
    value = converted.cents / 100.0
    totals['total'] = { 'value' => value, 'currency' => converted.currency.iso_code }
    totals
  end

  def handle_range_fee(fee:, cargo:, metadata_id:) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    measures = { kg: cargo.fetch(:weight),
                 cbm: cargo.fetch(:volume),
                 ton: cargo.fetch(:raw_weight, cargo.fetch(:weight)) / 1000.0,
                 wm: cargo.fetch(:weight_measure),
                 unit: cargo.fetch(:quantity, 1) }
    min = (fee['min'] || 0).to_d
    max = (fee['max'] || DEFAULT_MAX).to_d
    rate_basis = Legacy::RateBasis.get_internal_key(fee['rate_basis'])
    key = rate_basis[/PER_(.*?)_RANGE/m, 1]&.downcase
    res =
      case rate_basis
      when 'PER_UNIT_TON_CBM_RANGE'
        ratio = measures[:cbm] / measures[:ton]
        target = target_in_range(ranges: fee['range'], value: ratio, max: false)

        value = if target['ton']
                  target['ton'] * measures[:ton]
                elsif target['cbm']
                  target['cbm'] * measures[:cbm]
                else
                  target.fetch('rate', 0)
                end

        [value, min].max
      when /FLAT/
        measure = measures[key.to_sym]
        target = target_in_range(ranges: fee['range'], value: measure, max: false)
        target.fetch(key, 0)
      else
        measure = measures[key.to_sym]
        target = target_in_range(ranges: fee['range'], value: measure, max: true)
        target.fetch(key, 0) * measure
      end

    update_range_fee_metadata(key: fee[:key], final_range: target, metadata_id: metadata_id) if target.present?

    [res, max].min
  end

  def target_in_range(ranges:, value:, max: false)
    target = ranges.find do |step|
      Range.new(step['min'], step['max'], true).cover?(value)
    end

    target || (max ? ranges.max_by { |x| x['max'] } : { 'rate' => 0 })
  end

  def round_fee(result, should_round)
    if should_round
      result.to_d.round(2)
    else
      result
    end
  end

  def fee_value(fee:, cargo:, rounding: false, metadata_id: nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
               handle_range_fee(fee: fee, cargo: cargo, metadata_id: metadata_id)
             end

    return if result.nil?

    round_fee(result.clamp(min, max), rounding)
  end

  def get_cargo_hash(cargo, mot)
    if cargo.is_a? Legacy::Container
      {
        volume: (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight: (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
        raw_weight: (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
        weight_measure: (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
        quantity: cargo.try(:quantity) || 1
      }
    elsif cargo.is_a?(Hash)
      {
        volume: (cargo[:volume] || 1),
        weight: cargo[:chargeable_weight],
        raw_weight: cargo[:payload_in_kg],
        weight_measure: cargo[:chargeable_weight] / 1000.0,
        quantity: cargo[:num_of_items]
      }
    else
      chargeable_weight = cargo.calc_chargeable_weight(mot)

      {
        volume: (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight: (cargo.try(:weight) || chargeable_weight) * (cargo.try(:quantity) || 1),
        raw_weight: (cargo.try(:weight) || cargo.try(:payload_in_kg)) * (cargo.try(:quantity) || 1),
        weight_measure: (cargo.try(:weight) || chargeable_weight) * (cargo.try(:quantity) || 1) / 1000.0,
        quantity: cargo.try(:quantity) || 1
      }
    end
  end

  def get_manipulated_local_charge(local_charge, shipment, schedules, cargo_unit_id)
    return nil if local_charge.nil?

    Pricings::Manipulator.new(
      type: "#{local_charge.direction}_margin".to_sym,
      target: ::Organizations::User.find_by(id: shipment.user_id),
      organization: ::Organizations::Organization.find(shipment.organization_id),
      args: {
        cargo_class: local_charge.load_type,
        schedules: schedules,
        cargo_class_count: shipment.cargo_classes.count,
        local_charge: local_charge,
        sandbox: @sandbox,
        cargo_unit_id: cargo_unit_id
      }
    ).perform
  end

  def update_range_fee_metadata(key:, final_range:, metadata_id: nil)
    target_metadata = metadata.find { |m| m[:metadata_id] == metadata_id }
    return if target_metadata.blank?

    target_metadata.dig(:fees, key.to_sym, :breakdowns).each do |breakdown|
      next if breakdown.dig(:adjusted_rate, :range).blank?

      target_ranges = breakdown[:adjusted_rate][:range]
                      .select { |range| range.slice('min', 'max') == final_range.slice('min', 'max') }
      breakdown[:adjusted_rate][:rate] = target_ranges
    end
  end

  def cargos_for_loop(cargos:)
    if @scope.fetch(:consolidation, :cargo, :backend) && @shipment.load_type == 'cargo_item'
      [{ load_type: 'lcl', cargo_id: 'cargo_item' }]
    else
      cargos_to_use = @shipment.fcl? ? cargos.uniq(&:size_class) : cargos
      cargos_to_use.map do |cargo|
        {
          load_type: cargo.respond_to?(:size_class) ? cargo.size_class : 'lcl',
          cargo_id: cargo.id
        }
      end
    end
  end

  def user_groups
    companies = Companies::Membership.where(member: user)
    membership_ids = Groups::Membership.where(member: user)
                      .or(Groups::Membership.where(member: companies)).select(:group_id)
  end
end
