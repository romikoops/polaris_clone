# frozen_string_literal: true

require 'bigdecimal'

module OfferCalculator
  class TruckingTools # rubocop:disable Metrics/ClassLength
    LoadMeterageExceeded = Class.new(StandardError)

    LOAD_METERAGE_AREA_DIVISOR = 24_000
    CBM_VOLUME_DIVISOR = 1_000_000
    DEFAULT_MAX = Float::INFINITY
    TRUCKING_CONTAINER_HEIGHT = 260

    attr_accessor :trucking_pricing, :tenant, :user, :cargos, :kms, :carriage, :metadata
    def initialize(trucking_pricing, cargos, kms, carriage, user, metadata = [])
      @tenant = user.tenant
      @trucking_pricing = trucking_pricing
      @user = user
      @cargos = cargos
      @kms = kms
      @carriage = carriage
      @metadata = metadata
    end

    def perform
      direction = carriage == 'pre' ? 'export' : 'import'
      cargo_object = if trucking_pricing['load_type'] == 'container'
                       get_container_object(cargos)
                     else
                       cargo_item_object
                     end

      trucking_pricings = {}
      scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: user.id)).fetch
      return {} if trucking_pricing['rates'].empty?

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

      total[:currency] = @tenant.currency if total[:currency] == '' && total[:value].zero?

      fees[:total] = total
      fees
    end

    def apply_flat_margins(margins: {}, result:)
      result['value'] += margins.values.sum unless margins.empty?
    end

    def calculate_trucking_price(pricing, cargo, _direction, kms, scope)
      fees = {}
      result = {}
      total_fees = {}
      pricing = pricing.with_indifferent_access
      return {} if pricing.empty?

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
        extra_fees_results[tk] = [(tfee[:value] * fees[:rate][:value]), tfee[:min]].max
      end

      extra_fees_results.each do |_ek, evalue|
        result['value'] += evalue
      end

      apply_flat_margins(margins: pricing['flat_margins'] || {}, result: result)

      if !pricing[:rate]['min_value'] || (pricing[:rate]['min_value'] && result['value'] > pricing[:rate]['min_value'])
        { value: result['value'], currency: result['currency'] }
      else
        { value: pricing[:rate]['min_value'], currency: result['currency'] }
      end
    end

    def fare_calculator(key, fee, cargo, kms, scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      fee = fee.with_indifferent_access

      value = (fee['value'] || fee['rate'] || 0).to_d
      min = (fee[:min] || 0).to_d
      weight_value = fee[:rate_basis].include?('TON') ? cargo['weight'] / 1000 : cargo['weight']
      fare = case fee[:rate_basis]
             when 'PER_KG'
               cargo['weight'] * value
             when 'PER_X_KG', 'PER_X_TON'
               (weight_value / fee[:base]) * value
             when 'PER_X_KM'
               ((kms / fee[:x_base]) * value) + fee[:base_value]
             when 'PER_SHIPMENT'
               fee.except(:key, :rate_basis, :name, :currency, :base).values.max
             when 'PER_BILL'
               value
             when 'PER_ITEM', 'PER_CONTAINER', 'PER_UNIT'
               value * cargo['number_of_items']
             when 'PER_CONTAINER_KM'
               ((fee[:km] * kms) + fee[:unit]) * cargo['number_of_items']
             when 'PER_UNIT_KG'
               (fee[:kg]) + ((fee[:kgr] || 0)  * cargo['weight'])
             when 'PER_CBM_TON'
               cbm = cargo['volume'] * fee[:cbm]
               tonne = (cargo['weight'] / 1000) * fee[:ton]
               [tonne, cbm].max
             when 'PER_CBM'
               cargo['volume'] * (value || fee[:cbm])
             when 'PER_WM'
               wm = [cargo['weight'] / 1000, cargo['volume']].max
               wm * value
             when 'PER_CBM_KG'
               cbm_value = cargo['volume'] * fee[:cbm]
               kg_value = cargo['weight'] * fee[:kg]
               [kg_value, cbm_value].max

             when /RANGE/
               handle_range_fare(fee: fee, cargo: cargo)
             end
      final_fare = [fare, min].max
      final_result = round_fare(final_fare, scope['continuous_rounding'])
      { currency: fee[:currency], value: final_result, key: key }
    end

    def target_in_range(ranges:, value:, max: false)
      target = ranges.find do |step|
        Range.new(step['min'], step['max']).cover?(value)
      end

      target || (max ? ranges.max_by { |x| x['max'] } : { 'rate' => 0 })
    end

    def handle_range_fare(fee:, cargo:)
      weight_kg = cargo['weight']
      volume = cargo['volume']
      quantity = cargo['quantity'] || 1
      min = fee['min'] || 0
      max = fee['max'] || DEFAULT_MAX
      rate_basis = fee['rate_basis']
      case rate_basis
      when 'PER_KG_RANGE'
        target = target_in_range(ranges: fee['range'], value: weight_kg, max: true)
        value = target['rate'] * weight_kg

        res = [value, min].max
      when 'PER_CBM_RANGE'
        target = target_in_range(ranges: fee['range'], value: volume, max: true)

        res = target['rate'] * volume
      when 'PER_UNIT_TON_CBM_RANGE'
        ratio = volume / (weight_kg / 1000.0)
        target = target_in_range(ranges: fee['range'], value: ratio, max: false)
        value = if target['ton']
                  target['ton'] * weight_kg / 1000.0
                elsif target['cbm']
                  target['cbm'] * volume
                else
                  target.fetch('rate', 0)
                end

        res = [value, min].max
      when 'PER_CONTAINER_RANGE', 'PER_UNIT_RANGE'
        target = target_in_range(ranges: fee['range'], value: quantity, max: true)
        value = target.nil? ? 0 : target['rate']

        res = [value, min].max
      end
      update_range_fee_metadata(key: fee[:key], fee: target) if target.present?

      [res, max].min
    end

    def hard_limit_checker(rates:, key:, limit:, value:)
      last_rate = rates.compact.last[key].to_d
      decimal_value = value.to_d
      return false if last_rate > decimal_value

      raise OfferCalculator::TruckingTools::LoadMeterageExceeded if decimal_value > last_rate && limit

      true
    end

    def sort_ranges(ranges:)
      ranges.each_with_object({}) do |(modifier, range), result|
        result[modifier] = range.compact.sort_by { |range_fee| range_fee["max_#{modifier}"].to_d }
      end
    end

    def filter_trucking_pricings(trucking_pricing, cargo_values, scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      return {} if cargo_values['weight'].to_i.zero?

      all_ranges = sort_ranges(ranges: trucking_pricing['rates'])
      final_rate = case trucking_pricing['modifier']
                   when 'kg'
                     if hard_limit_checker(
                       rates: all_ranges['kg'],
                       key: 'max_kg',
                       value: cargo_values['weight'],
                       limit: scope['hard_trucking_limit']
                     )
                       last_rate = all_ranges['kg'].last
                       rate_to_return = last_rate['rate']
                       rate_to_return['min_value'] = last_rate['min_value']
                       update_trucking_rate_metadata(modifier: 'kg', min_max: last_rate.slice('min_kg', 'max_kg'))
                     end

                     all_ranges['kg'].each do |rate|
                       next unless trucking_rate_range_finder(
                         min: rate['min_kg'],
                         max: rate['max_kg'],
                         value: cargo_values['weight']
                       )

                       update_trucking_rate_metadata(modifier: 'kg', min_max: rate.slice('min_kg', 'max_kg'))
                       rate_to_return = rate['rate']
                       rate_to_return['min_value'] = rate['min_value']
                     end

                     rate_to_return
                   when 'cbm'
                     all_ranges['cbm'].each do |rate|
                       next unless trucking_rate_range_finder(
                         min: rate['min_cbm'],
                         max: rate['max_cbm'],
                         value: cargo_values['volume']
                       )

                       update_trucking_rate_metadata(modifier: 'cbm', min_max: rate.slice('min_cbm', 'max_cbm'))
                       rate_to_return = rate['rate']
                       rate_to_return['min_value'] = rate['min_value']
                     end
                     rate_to_return
                   when 'wm'
                     all_ranges['wm'].each do |rate|
                       wm = [cargo_values['volume'].to_d, cargo_values['weight'].to_d / 1000].max
                       next unless trucking_rate_range_finder(
                         min: rate['min_wm'],
                         max: rate['max_wm'],
                         value: wm
                       )

                       update_trucking_rate_metadata(modifier: 'wm', min_max: rate.slice('min_wm', 'max_wm'))
                       rate_to_return = rate['rate']
                       rate_to_return['min_value'] = rate['min_value']
                     end

                     rate_to_return
                   when 'cbm_kg'
                     result = {}
                     all_ranges['kg'].each do |rate|
                       next unless trucking_rate_range_finder(
                         min: rate['min_kg'],
                         max: rate['max_kg'],
                         value: cargo_values['weight']
                       )

                       update_trucking_rate_metadata(modifier: 'kg', min_max: rate.slice('min_kg', 'max_kg'))
                       result['kg'] = rate['rate']['value']
                       result['rate_basis'] = rate['rate']['rate_basis']
                       result['min_value'] = rate['min_value']
                       result['currency'] = rate['rate']['currency']
                     end
                     all_ranges['cbm'].each do |rate|
                       next unless trucking_rate_range_finder(
                         min: rate['min_cbm'],
                         max: rate['max_cbm'],
                         value: cargo_values['volume']
                       )

                       update_trucking_rate_metadata(modifier: 'cbm', min_max: rate.slice('min_cbm', 'max_cbm'))
                       result['rate_basis'] = rate['rate']['rate_basis']
                       result['cbm'] = rate['rate']['value']
                       result['min_value'] = rate['min_value']
                       result['currency'] = rate['rate']['currency']
                     end

                     if cargo_values['volume'] < all_ranges['cbm'].first['min_cbm'].to_d
                       result['rate_basis'] = all_ranges['cbm'].first['rate']['rate_basis']
                       result['cbm'] = all_ranges['cbm'].first['rate']['value']
                       result['min_value'] = all_ranges['cbm'].first['min_value']
                       result['currency'] = all_ranges['cbm'].first['rate']['currency']
                     elsif cargo_values['volume'] > all_ranges['cbm'].last['max_cbm'].to_d

                       result['rate_basis'] = all_ranges['cbm'].last['rate']['rate_basis']
                       result['cbm'] = all_ranges['cbm'].last['rate']['value']
                       result['min_value'] = all_ranges['cbm'].last['min_value']
                       result['currency'] = all_ranges['cbm'].last['rate']['currency']
                     end
                     result
                   when 'unit'
                     target_rate = trucking_pricing['rates']['unit'][0]
                     update_trucking_rate_metadata(modifier: 'unit', min_max: target_rate.slice('min_unit', 'max_unit'))
                     target_rate['rate']
                   when 'unit_per_km'
                     result = { rate_basis: 'PER_CONTAINER_KM' }
                     unit_rate = trucking_pricing.rates.dig('unit', 0)
                     km_rate = trucking_pricing.rates.dig('km', 0)
                     update_trucking_rate_metadata(modifier: 'km', min_max: km_rate.slice('min_km', 'max_km'))
                     update_trucking_rate_metadata(modifier: 'unit', min_max: unit_rate.slice('min_unit', 'max_unit'))
                     result[:unit] = unit_rate['rate']['value']
                     result[:km] = km_rate['rate']['value']
                     result[:min_value] = trucking_pricing['rates']['unit'][0]['min_value']
                     result[:currency] = trucking_pricing['rates']['unit'][0]['rate']['currency']

                     result
                   when 'unit_and_kg'
                     result = { rate_basis: 'PER_UNIT_KG' }
                     result[:min_value] = all_ranges['kg'][0]['min_value']
                     result[:currency] = all_ranges['kg'][0]['rate']['currency']

                     if hard_limit_checker(
                       rates: all_ranges['kg'],
                       key: 'max_kg',
                       value: cargo_values['weight'],
                       limit: scope['hard_trucking_limit']
                     )
                       rate = all_ranges['kg'].last
                       rate['rate']['min_value'] = rate['min_value']
                       result[:kg] = rate['rate']['value']
                     end

                     all_ranges['kg'].each do |range_rate|
                       next unless trucking_rate_range_finder(
                         min: range_rate['min_kg'],
                         max: range_rate['max_kg'],
                         value: cargo_values['weight']
                       )

                       range_rate['rate']['min_value'] = range_rate['min_value']
                       result[:kg] = range_rate['rate']['value']
                     end

                     if rate.present?
                       update_trucking_rate_metadata(
                         modifier: 'kg',
                         min_max: rate.slice('min_kg', 'max_kg')
                       )
                     end
                     all_ranges['unit_in_kg'].each do |unit_kg_rate|
                       next unless trucking_rate_range_finder(
                         min: unit_kg_rate['min_unit_in_kg'],
                         max: unit_kg_rate['max_unit_in_kg'],
                         value: cargo_values['weight']
                       )

                       update_trucking_rate_metadata(
                         modifier: 'unit_in_kg',
                         min_max: unit_kg_rate.slice('min_unit_in_kg', 'max_unit_in_kg')
                       )
                       unit_kg_rate['rate']['min_value'] = unit_kg_rate['min_value']
                       result[:kgr] = unit_kg_rate['rate']['value']
                     end

                     result
                   end

      { rate: final_rate, fees: trucking_pricing['fees'], flat_margins: trucking_pricing['flat_margins'] }
    end

    def cargo_item_object # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
      consolidation = ::Tenants::ScopeService.new(
        target: ::Tenants::User.find_by(legacy_id: cargos.first.shipment.user.id)
      ).fetch(:consolidation)

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

      target = "#{trucking_pricing['carriage'] || trucking_pricing.scope.carriage}_carriage"
      total_chargeable_weight =
        cargo_object.dig('stackable', 'weight') + cargo_object.dig('non_stackable', 'weight')
      cargos.first.shipment.set_trucking_chargeable_weight(target, total_chargeable_weight)

      cargo_object
    end

    def consolidated_trucking_cargo(trucking_pricing, cargo_object, cargos)
      cargo = if cargos.first.is_a? Legacy::AggregatedCargo
                cargos.first
              else
                consolidate_cargo(cargos)
              end
      determine_load_meterage(trucking_pricing, cargo_object, cargo)
    end

    def consolidate_cargo(cargo_array) # rubocop:disable Metrics/AbcSize
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
      if cargos.first.is_a? Legacy::AggregatedCargo
        total_area =  cargos.first.volume / 1.3
        non_stackable = false
      else
        total_area =  cargos.sum do |cargo|
          cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo) * cargo.quantity
        end
        non_stackable = cargos.select(&:stackable).empty?
      end

      load_area_limit = trucking_pricing['load_meterage']['area_limit'] || DEFAULT_MAX
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

    def comparative_load_meterage(trucking_pricing, cargo_object, cargos) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      total_load_meterage_weight = 0.0
      total_cbm_weight = 0.0
      total_payload_weight = 0.0
      total_area = 0.0
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
      total_load_meters = total_load_meterage_weight / trucking_pricing['load_meterage']['ratio']
      if total_load_meters >= (trucking_pricing['load_meterage']['ldm_limit'] || DEFAULT_MAX)
        effective_weight = [total_load_meterage_weight, total_cbm_weight, total_payload_weight].max
        stackable_key = effective_weight == total_load_meterage_weight ? 'non_stackable' : 'stackable'
      else
        effective_weight = [total_cbm_weight, total_payload_weight].max
        stackable_key = 'stackable'
      end

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

    def determine_load_meterage(trucking_pricing, cargo_object, cargo) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      total_area = (cargo.try(:dimension_x) || 1) * (cargo.try(:dimension_y) || 1) * (cargo.try(:quantity) || 1)
      if trucking_pricing['load_meterage'] && trucking_pricing['load_meterage']['ratio']
        if cargo.is_a? Legacy::AggregatedCargo
          calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
        elsif (trucking_pricing['load_meterage']['height_limit'] &&
            (cargo[:dimension_z] > trucking_pricing['load_meterage']['height_limit'])) ||
              (!cargo[:stackable] && trucking_pricing['load_meterage']['height_limit'])
          calc_cargo_load_meterage_height(trucking_pricing, cargo_object, cargo)
        elsif (trucking_pricing['load_meterage']['area_limit'] &&
          (total_area >= trucking_pricing['load_meterage']['area_limit'])) ||
              (!cargo[:stackable] && trucking_pricing['load_meterage']['area_limit'])
          calc_cargo_load_meterage_area(trucking_pricing, cargo_object, cargo)
        else
          calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
        end
      elsif cargo.is_a? Legacy::AggregatedCargo
        calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      else
        calc_cargo_cbm_ratio(trucking_pricing, cargo_object, cargo)
      end

      cargo_object
    end

    def calc_aggregated_cargo_load_meterage(trucking_pricing, cargo_object, cargo)
      volume = cargo_volume(cargo)
      load_meterage = (volume / 1.3) / 2.4
      load_meter_weight = load_meterage * trucking_pricing['load_meterage']['ratio']
      trucking_chargeable_weight = load_meter_weight > cargo.weight ? load_meter_weight : cargo.weight
      cargo_object['non_stackable']['weight'] += trucking_chargeable_weight
      cargo_object['non_stackable']['volume'] += volume
      cargo_object['non_stackable']['number_of_items'] = 1

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
      area_var = cargo_unit_area(cargo) * cargo_quantity(cargo)
      load_meter_var = area_var / LOAD_METERAGE_AREA_DIVISOR
      load_meter_var * trucking_pricing['load_meterage']['ratio']
    end

    def trucking_chargeable_weight_by_height(trucking_pricing, cargo)
      load_meterage = (
          cargo_unit_area(cargo) / LOAD_METERAGE_AREA_DIVISOR
        ) * cargo_quantity(cargo)
      load_meterage * trucking_pricing['load_meterage']['ratio']
    end

    def trucking_chargeable_weight_by_stacked_area(trucking_pricing, cargo)
      items_per_stack = (TRUCKING_CONTAINER_HEIGHT / cargo_data_value(:dimension_z, cargo)).floor
      num_stacks = (cargo_quantity(cargo) / items_per_stack.to_d).ceil
      stacked_area = cargo_unit_area(cargo) * num_stacks
      load_meter_var = stacked_area / LOAD_METERAGE_AREA_DIVISOR
      load_meter_var * trucking_pricing['load_meterage']['ratio']
    end

    def trucking_cbm_weight(trucking_pricing, cargo)
      cbm_ratio = trucking_pricing['cbm_ratio'] || 0
      volume = cargo_volume(cargo)
      volume * cbm_ratio
    end

    def cargo_volume(cargo)
      if cargo.is_a?(Legacy::AggregatedCargo)
        cargo.volume
      else
        cargo_unit_volume(cargo) * cargo_quantity(cargo)
      end
    end

    def cargo_unit_volume(cargo)
      if cargo.is_a?(Legacy::AggregatedCargo)
        cargo.volume
      elsif cargo.is_a?(Hash)
        cargo[:volume]
      else
        (cargo[:dimension_x] * cargo[:dimension_y] * cargo[:dimension_z]) / CBM_VOLUME_DIVISOR
      end
    end

    def cargo_quantity(cargo)
      if cargo.is_a?(Legacy::AggregatedCargo)
        1
      elsif cargo.is_a?(Hash)
        cargo[:quantity] || 1
      else
        cargo.quantity
      end
    end

    def cargo_unit_area(cargo)
      if cargo.is_a?(Legacy::AggregatedCargo)
        Legacy::AggregatedCargo::DEFAULT_HEIGHT
      else
        cargo_data_value(:dimension_x, cargo) * cargo_data_value(:dimension_y, cargo)
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

    def update_trucking_rate_metadata(modifier:, min_max:)
      cargo_class_key = "trucking_#{trucking_pricing[:cargo_class]}".to_sym
      target_metadata = metadata.find { |m| m[:metadata_id] == trucking_pricing[:metadata_id] }
      return if target_metadata.blank?

      target_metadata.dig(:fees, cargo_class_key, :breakdowns).each do |breakdown|
        next if breakdown[:adjusted_rate].blank?

        target_ranges = breakdown[:adjusted_rate][modifier].select { |range| range.slice(*min_max.keys) == min_max }
        breakdown[:adjusted_rate][modifier] = target_ranges
      end
    end

    def update_range_fee_metadata(key:, fee:)
      target_metadata = metadata.find { |m| m[:metadata_id] == trucking_pricing[:metadata_id] }
      return if target_metadata.blank?

      target_metadata.dig(:fees, key.to_sym, :breakdowns)&.each do |breakdown|
        next if breakdown[:adjusted_rate].blank?

        target_ranges = breakdown[:adjusted_rate][:range]
                        .select { |range| range.slice(:min, :max) == fee.slice(:min, :max) }
        breakdown[:adjusted_rate][:rate] = target_ranges
      end
    end

    def trucking_rate_range_finder(min:, max:, value:)
      min.to_d < value.to_d && value.to_d <= max.to_d
    end
  end
end
