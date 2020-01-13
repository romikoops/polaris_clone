# frozen_string_literal: true

require 'bigdecimal'
module Pricings
  class Calculator # rubocop:disable Metrics/ClassLength
    def initialize(cargo:, pricing:, user:, mode_of_transport:, date:)
      @user = user
      @mot = mode_of_transport
      @cargo = cargo
      @data = pricing.with_indifferent_access
      @pricing = @data[:data]
      @margins = @data[:flat_margins] || {}
      @metadata_id = @data[:metadata_id]
      @converter = Pricings::Conversion.new(base: @user.currency, tenant_id: @user.tenant_id)
      @totals = Hash.new { |h, k| h[k] = { 'value' => 0, 'currency' => nil } unless k.to_s == 'metadata_id' }
      @date = date
    end

    DEFAULT_MAX = Float::INFINITY

    def perform
      return nil if @pricing.nil?

      calculate_fees
      convert_fees

      @totals.with_indifferent_access.merge('metadata_id' => @metadata_id)
    end

    def calculate_fees
      @pricing.keys.each do |k|
        fee = @pricing[k].clone
        @totals[k]['currency'] ||= fee['currency']
        @totals[k]['value'] +=
          if fee['hw_rate_basis']
            heavy_weight_fee_value(fee, @user.tenant.scope)
          else
            fee_value(fee, get_cargo_hash, @user.tenant.scope)
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
      converted = @converter.sum_and_convert_cargo(@totals)
      @cargo.try(:unit_price=, value: converted, currency: @user.currency)
      @totals['total'] = { value: converted, currency: @user.currency }
    end

    def target_in_range(ranges:, value:, max: false)
      target = ranges.find do |step|
        Range.new(step['min'],step['max']).cover?(value)
      end

      target || (max ? ranges.max_by { |x| x['max'] } : 0)
    end

    def handle_range_fee(fee, cargo_hash) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      weight_kg = cargo_hash.fetch(:weight)
      raw_weight_kg = cargo_hash.fetch(:raw_weight)
      volume = cargo_hash.fetch(:volume)
      min = fee['min'] || 0
      max = fee['max'] || DEFAULT_MAX
      rate_basis = Pricings::RateBasis.get_internal_key(fee['rate_basis'])
      case rate_basis
      when 'PER_KG_RANGE'
        target = target_in_range(ranges: fee['range'], value: weight_kg, max: true)
        value = target['rate'] * weight_kg

        res = [value, min].max
      when 'PER_CBM_RANGE'
        target = target_in_range(ranges: fee['range'], value: volume, max: true)

        res = target['rate'] * volume
      when 'PER_UNIT_TON_CBM_RANGE'
        ratio = volume / (raw_weight_kg / 1000)
        target = target_in_range(ranges: fee['range'], value: ratio, max: false)
        value = if target == 0
                  0
                elsif target['ton']
                  target['ton'] * raw_weight_kg / 1000
                elsif target['cbm']
                  target['cbm'] * volume
                end

        res = [value, min].max
      when 'PER_CONTAINER_RANGE'
        target = target_in_range(ranges: fee['range'], value: weight_kg, max: true)
        value = target.nil? ? 0 : target['rate']

        res = [value, min].max
      when 'PER_UNIT_RANGE'
        target = target_in_range(ranges: fee['range'], value: weight_kg, max: true)
        value = target.nil? ? 0 : target['rate']

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
          quantity: @cargo.try(:quantity) || 1
        }
      elsif @cargo.is_a?(Hash)
        {
          volume: (@cargo[:volume] || 1),
          weight: @cargo[:chargeable_weight],
          raw_weight: @cargo[:payload_in_kg],
          quantity: @cargo[:num_of_items]
        }
      else
        chargeable_weight = @cargo.calc_chargeable_weight(@mot)
        {
          volume: (@cargo.try(:volume) || 1) * (@cargo.try(:quantity) || 1),
          weight: (@cargo.try(:weight) || chargeable_weight) * (@cargo.try(:quantity) || 1),
          raw_weight: (@cargo.try(:weight) || @cargo.try(:payload_in_kg)) * (@cargo.try(:quantity) || 1),
          quantity: @cargo.try(:quantity) || 1
        }
      end
    end
  end
end
