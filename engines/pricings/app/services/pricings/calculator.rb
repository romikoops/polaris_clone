# frozen_string_literal: true

require 'bigdecimal'
module Pricings
  class Calculator # rubocop:disable Metrics/ClassLength
    def initialize(cargo:, pricing:, user:, mode_of_transport:, date:, metadata: [])
      @user = user
      @mot = mode_of_transport
      @cargo = cargo
      @data = pricing.with_indifferent_access
      @pricing = @data[:data]
      @margins = @data[:flat_margins] || {}
      @metadata_id = @data[:metadata_id]
      @metadata = metadata
      @scope = Tenants::ScopeService.new(tenant: Tenants::Tenant.find_by(legacy_id: user.tenant_id)).fetch
      @totals = Hash.new { |h, k| h[k] = { 'value' => 0, 'currency' => nil } unless k.to_s == 'metadata_id' }
      @date = date
    end

    DEFAULT_MAX = Float::INFINITY

    def perform
      return nil if @pricing.nil?

      calculate_fees
      convert_fees

      [@totals.with_indifferent_access.merge('metadata_id' => @metadata_id), metadata]
    end

    def calculate_fees
      @pricing.keys.each do |k|
        fee = @pricing[k].clone.merge(key: k)

        @totals[k]['currency'] ||= fee['currency']
        @totals[k]['value'] +=
          if fee['hw_rate_basis']
            heavy_weight_fee_value(fee, @scope)
          else
            fee_value(fee, get_cargo_hash, @scope)
          end
      end

      apply_margins
    end

    def apply_margins
      @margins.each_key do |margin_key|
        @totals[margin_key]['value'] += @margins[margin_key]
      end

      @totals
    end

    def convert_fees
      converted = ::Legacy::ExchangeHelper.sum_and_convert_cargo(@totals, @user.currency)
      @totals['total'] = { value: converted.cents / 100.0, currency: converted.currency.to_s }
    end

    def target_in_range(ranges:, value:, max: false)
      target = ranges.find do |step|
        Range.new(step['min'], step['max'], true).cover?(value)
      end

      target || (max ? ranges.max_by { |x| x['max'] } : { 'rate' => 0 })
    end

    def handle_range_fee(fee, cargo_hash) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      measures = { kg: cargo_hash.fetch(:weight),
                   cbm: cargo_hash.fetch(:volume),
                   ton: cargo_hash.fetch(:raw_weight, cargo_hash.fetch(:weight)) / 1000.0,
                   wm: cargo_hash.fetch(:weight_measure),
                   unit: cargo_hash.fetch(:quantity, 1) }
      min = fee['min'] || 0
      max = fee['max'] || DEFAULT_MAX
      rate_basis = Pricings::RateBasis.get_internal_key(fee['rate_basis'])
      key = rate_basis[/PER_(.*?)_RANGE/m, 1]&.downcase
      key = 'unit' if key == 'container'
      value = case rate_basis
              when 'PER_UNIT_TON_CBM_RANGE'
                ratio = measures[:cbm] / measures[:ton]
                target = target_in_range(ranges: fee['range'], value: ratio, max: false)
                if target['ton']
                  target['ton'] * measures[:ton]
                elsif target['cbm']
                  target['cbm'] * measures[:cbm]
                else
                  target.fetch('rate', 0)
                end
              when /FLAT/
                measure = measures[key.to_sym]
                target = target_in_range(ranges: fee['range'], value: measure, max: false)
                target.fetch('rate', 0)
              else
                measure = measures[key.to_sym]
                target = target_in_range(ranges: fee['range'], value: measure, max: true)
                target.fetch('rate', 0) * measure
              end
      update_range_fee_metadata(key: fee[:key], final_range: target) if target.present?
      res = [value, min].max
      [res, max].min
    end

    def round_fee(result, should_round)
      if should_round
        result.to_d.round(2)
      else
        result
      end
    end

    def heavy_weight_fee_value(fee, scope) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      weight_kg = @cargo.try(:weight) || @cargo.try(:payload_in_kg)
      quantity  = @cargo.try(:quantity) || 1
      cbm = @cargo.volume
      ton = weight_kg / 1000
      rate_basis = Pricings::RateBasis.get_internal_key(fee['hw_rate_basis'])
      result = case rate_basis
               when 'CBM_PER_KG'
                 ratio = weight_kg / cbm
                 rate_value = [cbm, ton].max * quantity * fee['rate'].to_i if ratio > fee['hw_threshold']

                 [rate_value, fee['min']].max
               when 'PER_ITEM'
                 max_fee = fee['range'].max_by { |x| x['max'] }
                 fee_range = max_fee if weight_kg > max_fee['max']
                 fee_range ||= fee['range'].find do |range|
                   (range['min']..range['max']).cover?(weight_kg)
                 end

                 fee_range.nil? ? 0 : fee_range['rate'] * quantity
               end

      round_fee(result, scope['continuous_rounding'])
    end

    def fee_value(fee, cargo_hash, scope) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      rate_basis = fee['rate_basis']
      fee_value = fee['value'] || fee['rate']
      result = case rate_basis
               when 'PER_SHIPMENT', 'PER_BILL'
                 fee_value.to_d
               when 'PER_ITEM', 'PER_CONTAINER'
                 fee_value.to_d * cargo_hash[:quantity]
               when 'PER_CBM'
                 min = fee['min'] || 0
                 max = fee['max'] || DEFAULT_MAX
                 val = fee_value
                 cbm = val.to_d * cargo_hash[:volume]
                 res = [cbm, min].max
                 [res, max].min
               when 'PER_KG'
                 max = fee['max'] || DEFAULT_MAX
                 val = fee_value.to_d * cargo_hash[:weight]
                 min = fee['min'] || 0
                 res = [val, min].max
                 [res, max].min
               when 'PER_X_KG_FLAT'
                 max = fee['max'] || DEFAULT_MAX
                 base = fee['base'].to_d
                 val = fee_value * (cargo_hash[:weight].round(2) / base).ceil * base
                 min = fee['min'] || 0
                 res = [val, min].max
                 [res, max].min
               when 'PER_TON'
                 max = fee['max'] || DEFAULT_MAX
                 ton = (cargo_hash[:weight] / 1000) * fee_value
                 min = fee['min'] || 0
                 res = [ton, min].max
                 [res, max].min
               when 'PER_WM'
                 max = fee['max'] || DEFAULT_MAX
                 cbm = cargo_hash[:volume] * fee_value
                 ton = (cargo_hash[:weight] / 1000) * fee_value
                 min = fee['min'] || 0
                 res = [cbm, ton, min].max

                 [res, max].min
               when /RANGE/
                 handle_range_fee(fee, cargo_hash)
               end

      round_fee(result, scope['continuous_rounding'])
    end

    def get_cargo_hash # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Naming/AccessorMethodName
      if @cargo.is_a? ::Legacy::Container
        {
          volume: (@cargo.try(:volume) || 1) * (@cargo.try(:quantity) || 1),
          weight: (@cargo.try(:weight) || @cargo.payload_in_kg) * (@cargo.try(:quantity) || 1),
          raw_weight: (@cargo.try(:weight) || @cargo.payload_in_kg) * (@cargo.try(:quantity) || 1),
          weight_measure: (@cargo.try(:weight) || @cargo.payload_in_kg) * (@cargo.try(:quantity) || 1) / 1000.0,
          quantity: @cargo.try(:quantity) || 1
        }
      elsif @cargo.is_a?(Hash)
        {
          volume: (@cargo[:volume] || 1),
          weight: @cargo[:chargeable_weight],
          weight_measure: @cargo[:chargeable_weight] / 1000.0,
          raw_weight: @cargo[:payload_in_kg],
          quantity: @cargo[:num_of_items] || 1
        }
      else
        chargeable_weight = @cargo.calc_chargeable_weight(@mot)
        {
          volume: (@cargo.try(:volume) || 1) * (@cargo.try(:quantity) || 1),
          weight: (@cargo.try(:weight) || chargeable_weight) * (@cargo.try(:quantity) || 1),
          raw_weight: (@cargo.try(:weight) || @cargo.try(:payload_in_kg)) * (@cargo.try(:quantity) || 1),
          weight_measure: (@cargo.try(:weight) || chargeable_weight) * (@cargo.try(:quantity) || 1) / 1000.0,
          quantity: @cargo.try(:quantity) || 1
        }
      end
    end

    def update_range_fee_metadata(key:, final_range:)
      target_metadata = metadata.find { |m| m[:metadata_id] == metadata_id }
      return if target_metadata.blank?

      target_metadata.dig(:fees, key.to_sym, :breakdowns).each do |breakdown|
        next if breakdown.blank? || breakdown.dig(:adjusted_rate, :range).blank?

        target_ranges = breakdown[:adjusted_rate][:range]
                        .select { |range| range.slice(:min, :max) == final_range.slice(:min, :max) }
        breakdown[:adjusted_rate][:rate] = target_ranges
      end
    end

    attr_accessor :metadata, :metadata_id
  end
end
