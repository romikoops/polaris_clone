# frozen_string_literal: true

require 'bigdecimal'

class OfferCalculator::PricingTools # rubocop:disable Metrics/ClassLength
  attr_accessor :scope, :user, :shipment, :metadata
  attr_reader :currency

  def initialize(user:, shipment: nil, metadata: [])
    @user = user
    @shipment = shipment
    @target = @user
    @organization = ::Organizations::Organization.find(shipment.organization_id)
    @target ||= Groups::Group.find_by(name: 'default', organization_id: shipment.organization_id)
    @scope = ::OrganizationManager::ScopeService.new(
      target: @target,
      organization: @organization
    )
    @metadata = metadata
    @currency = Users::Settings.find_by(user: user)&.currency || @scope.fetch(:default_currency)
  end

  DEFAULT_MAX = Float::INFINITY

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

    converted = ::Legacy::ExchangeHelper.sum_and_convert_cargo(totals, currency)
    value = converted.cents / 100.0
    totals['total'] = { 'value' => value, 'currency' => converted.currency.iso_code }
    totals
  end

  def handle_range_fee(fee:, cargo:, metadata_id:) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
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
    [res, max].min
  end

  def target_in_range(ranges:, value:, max: false)
    target = ranges.find do |step|
      Range.new(step['min'], step['max'], true).cover?(value)
    end

    target || (max ? ranges.max_by { |x| x['max'] } : { 'rate' => 0 })
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

    result.clamp(min, max)
  end
end
