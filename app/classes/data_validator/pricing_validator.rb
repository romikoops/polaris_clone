# frozen_string_literal: true

module DataValidator
  class PricingValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object
    include OfferCalculatorService
    include AwsConfig
    include DocumentService

    def post_initialize(args)
      signed_url = get_file_url(args[:key], 'assets.itsmycargo.com')
      @xlsx = open_file(signed_url)
      @shipment_ids_to_destroy = []
      @user = args[:user] || @tenant.users.shipper.first
      @dummy_data = args[:data]
      @validation_results = {}
      @row_keys = {}
      @cargo_unit_keys = []
      @fee_keys = {}
      @examples = []
      @sheet_rows = []
      tenants_tenant = Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
      @scope         = ::Tenants::ScopeService.new(
        target: ::Tenants::User.find_by(legacy_id: @user.id),
        tenant: tenants_tenant
      ).fetch
    end

    def perform
      @xlsx.each_with_pagename do |sheet_name, sheet|
        @sheet = sheet
        begin
          @examples = []
          create_sheet_rows

          create_cargo_key_hash

          create_fees_key_hash('import')

          create_fees_key_hash('export')

          create_fees_key_hash('freight')

          create_example_results
          calculate(sheet_name)
        rescue Exception => e # bad code.....
          raise ApplicationError::BadData
        end
      end

      Shipment.where(id: @shipment_ids_to_destroy).destroy_all
      print_results
    end

    def calculate(sheet_name)
      @examples.each do |example|
        @example = example
        @load_type = @example[:data][:load_type]
        puts @example[:data][:pickup_address]
        price_check(@example, sheet_name)
      end
    end

    private

    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def create_sheet_rows
      start = @sheet.first_row
      @sheet_rows = []
      while start <= @sheet.last_row
        row = @sheet.row(start)
        @sheet_rows << row
        @row_keys[row.first] = start - 1
        start += 1
      end
    end

    def create_cargo_key_hash
      units_index = @row_keys['UNITS']
      @cargo_unit_keys = []
      current_index = units_index + 2
      all_units = false
      until all_units
        row = @sheet.row(current_index)
        if row&.first&.include?('#')
          str = row.first.sub('#', '')
          str_index, attribute = str.split('-')
          cargo_index = str_index.to_i
          @cargo_unit_keys[cargo_index] = {} unless @cargo_unit_keys[cargo_index]
          @cargo_unit_keys[cargo_index][attribute] = current_index - 1
          current_index += 1
        else
          all_units = true
        end
      end
    end

    def create_fees_key_hash(target)
      units_index = @row_keys[target.upcase]
      current_index = units_index + 2
      all_keys = false
      until all_keys
        row = @sheet.row(current_index)
        if row.first&.include?('-')
          attribute = row.first.sub('-', '').strip
          @fee_keys[target] = {} unless @fee_keys[target]
          @fee_keys[target][attribute] = current_index - 1
          current_index += 1
        else
          all_keys = true
        end
      end
    end

    def create_example_results # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      column_index = 2
      all_columns = false
      until all_columns
        column = @sheet.column(column_index)
        if column.first.blank?
          all_columns = true
        else
          result = {
            expected: {
              total: get_top_value_currency(column, 'TOTAL'),
              trucking_pre: get_top_value_currency(column, 'PRECARRIAGE'),
              trucking_on: get_top_value_currency(column, 'ONCARRIAGE'),
              cargo: get_top_value_currency(column, 'FREIGHT'),
              export: get_top_value_currency(column, 'EXPORT'),
              import: get_top_value_currency(column, 'IMPORT')
            },
            data: {
              cargo_units: extract_cargo_units_from_column(column),
              pickup_address: column[@row_keys['PICKUP_ADDRESS']],
              delivery_address: column[@row_keys['DELIVERY_ADDRESS']],
              load_type: column[@row_keys['LOAD_TYPE']],
              origin_truck_type: column[@row_keys['ORIGIN_TRUCK_TYPE']],
              destination_truck_type: column[@row_keys['DESTINATION_TRUCK_TYPE']],
              mode_of_transport: column[@row_keys['MOT']],
              service_level: column[@row_keys['SERVICE_LEVEL']],
              carrier: column[@row_keys['CARRIER']],
              date: column[@row_keys['DATE']],
              itinerary: @tenant.itineraries.find_by(name: column[@row_keys['ITINERARY']], mode_of_transport: column[@row_keys['MOT']])
            },
            result_index: column_index
          }

          @fee_keys.deep_symbolize_keys!
          @fee_keys.each do |direction, fees|
            target_key = direction == :freight ? :cargo : direction
            fees.each do |fee_key, row_index|
              result[:expected][target_key] = {} unless result[:expected][target_key]
              result[:expected][target_key][fee_key.to_sym] = string_to_currency_value(column[row_index])
            end
          end
          @examples << result
          column_index += 1
        end
      end
    end

    def string_to_currency_value(str)
      return nil unless str

      currency, value = str.split(' ')
      { value: value, currency: currency }
    end

    def extract_cargo_units_from_column(column)
      cargos = []
      @cargo_unit_keys.compact.each do |key_hash|
        next unless column[key_hash.values.first]

        new_cargo = {}
        key_hash.each do |key, value|
          if key == 'quantity' && @scope.dig('consolidation', 'cargo', 'frontend')
            new_cargo['payload_in_kg'] = new_cargo['payload_in_kg'].to_d / column[value].to_d
          end
          new_cargo[key] = column[value]
        end
        cargos << new_cargo
      end

      cargos
    end

    def get_top_value_currency(column, key)
      str = column[@row_keys[key]]
      to_display = string_to_currency_value(str)
      return {} if to_display.nil?

      return to_display if key == 'TOTAL'

      { total: to_display }
    end

    def price_check(example, sheet_name) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      @destination_hub = example[:data][:itinerary].last_stop.hub
      @origin_hub = example[:data][:itinerary].first_stop.hub
      @shipment = Shipment.create!(
        user: @user,
        tenant: @tenant,
        load_type: example[:data][:load_type],
        planned_pickup_date: example[:data][:date],
        origin_hub: @origin_hub,
        destination_hub: @destination_hub,
        trucking: determine_trucking_hash(example)
      )
      @shipment_ids_to_destroy << @shipment.id
      @shipment.cargo_units = prep_cargo_units(example)
      @hubs = { origin: [@origin_hub], destination: [@destination_hub] }
      @trucking_data_builder = OfferCalculatorService::TruckingDataBuilder.new(@shipment)
      @trucking_data = @trucking_data_builder.perform(@hubs)

      @data_for_price_checker = example[:data]
      @data_for_price_checker[:trucking] = @trucking_data
      @data_for_price_checker[:shipment] = @shipment
      @data_for_price_checker[:itinerary] = example[:data][:itinerary]
      @data_for_price_checker[:has_on_carriage] = example[:data][:delivery_address]
      @data_for_price_checker[:has_pre_carriage] = example[:data][:pickup_address]
      @data_for_price_checker[:service_level] = @tenant.tenant_vehicles.find_by(
        name: example[:data][:service_level],
        carrier: Carrier.find_by(name: example[:data][:carrier]),
        mode_of_transport: example[:data][:mode_of_transport]
      )
      @data_for_price_checker[:schedules] = prep_faux_schedules(example)

      @data_for_price_checker[:cargo_units] = example[:data][:cargo_units]
      @data_for_price_checker[:pricing] = determine_pricing(@example)
      validate_prices(sheet_name, example[:data][:itinerary], @data_for_price_checker, example[:expected], example[:result_index], example[:data])
    end

    def determine_pricing(example) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      base_date = example[:data][:date]
      schedules = example[:data][:schedules]
      result_to_return = []
      cargo_classes = @shipment.aggregated_cargo ? ['lcl'] : @shipment.cargo_units.pluck(:cargo_class)
      schedules.sort_by!(&:eta)

      dates = extract_dates_and_quote(schedules)
      user_pricing_id = @scope['base_pricing'] ? user.id : user.pricing_id

      # Find the pricings for the cargo classes and effective date ranges then group by cargo_class

      pricings_by_cargo_class = sort_pricings(
        schedules: schedules,
        user_pricing_id: user_pricing_id,
        cargo_classes: cargo_classes,
        dates: dates,
        dedicated_pricings_only: dedicated_pricings?(user)
      )
      most_diverse_set = pricings_by_cargo_class.values.max_by(&:length)
      other_pricings = pricings_by_cargo_class
                       .values
                       .reject { |pricing_group| pricing_group == most_diverse_set }
                       .flatten
      if @scope['base_pricing']
        # Find the group with the most pricings and create the object to be passed on

        if most_diverse_set.nil?
          result_to_return << nil
        else
          most_diverse_set.each do |pricing|
            schedules_for_obj = schedules.dup
            unless dates[:is_quote]
              schedules_for_obj.select! do |sched|
                sched.etd < pricing[:expiration_date] && sched.etd > pricing[:effective_date]
              end
              if schedules_for_obj.empty?
                schedules_for_obj = schedules.select do |sched|
                  sched.closing_date < pricing[:expiration_date] &&
                    sched.closing_date > pricing[:effective_date]
                end
              end
            end
            cargo_class_key = pricing[:cargo_class]
            obj = {
              pricing_ids: {
                cargo_class_key => pricing
              },
              schedules: schedules_for_obj
            }

            other_pricings.each do |other_pricing|
              other_cargo_class_key = other_pricing[:cargo_class]
              if other_pricing[:effective_date] < dates[:start_date] &&
                 other_pricing[:expiration_date] > dates[:end_date]
                obj[:pricing_ids][other_cargo_class_key] =
                  other_pricing
              end
              if dates[:start_date] && dates[:end_date] &&
                 obj[:pricing_ids][other_cargo_class_key].nil? &&
                 other_pricing[:effective_date] < dates[:start_date] &&
                 other_pricing[:expiration_date] > dates[:end_date]
                obj[:pricing_ids][other_cargo_class_key] =
                  other_pricing
              end
              next unless obj[:pricing_ids][other_cargo_class_key].nil? &&
                          other_pricing[:effective_date] < obj[:schedules].first.closing_date &&
                          other_pricing[:expiration_date] > obj[:schedules].last.closing_date

              obj[:pricing_ids][other_cargo_class_key] = other_pricing
            end
            result_to_return << obj
          end
        end
      else
        if most_diverse_set.nil?
          result_to_return << nil
        else
          most_diverse_set.each do |pricing| # rubocop:disable Metrics/BlockLength
            schedules_for_obj = schedules.dup
            unless dates[:is_quote]
              schedules_for_obj.select! do |sched|
                sched.etd < pricing.expiration_date && sched.etd > pricing.effective_date
              end
              if schedules_for_obj.empty?
                schedules_for_obj = schedules.select do |sched|
                  sched.closing_date < pricing.expiration_date &&
                    sched.closing_date > pricing.effective_date
                end
              end
            end
            cargo_class_key = pricing.try(:cargo_class) || pricing.transport_category.cargo_class.to_s
            obj = {
              pricing_ids: {
                cargo_class_key => pricing.id
              },
              schedules: schedules_for_obj
            }

            other_pricings.each do |other_pricing|
              other_cargo_class_key = other_pricing.try(:cargo_class) || other_pricing.transport_category.cargo_class.to_s
              if other_pricing.effective_date < dates[:start_date] &&
                 other_pricing.expiration_date > dates[:end_date]
                obj[:pricing_ids][other_cargo_class_key] =
                  other_pricing.id
              end
              if dates[:start_date] && dates[:end_date] &&
                 obj[:pricing_ids][other_cargo_class_key].nil? &&
                 other_pricing.effective_date < dates[:start_date] &&
                 other_pricing.expiration_date > dates[:end_date]
                obj[:pricing_ids][other_cargo_class_key] =
                  other_pricing.id
              end
              next unless obj[:pricing_ids][other_cargo_class_key].nil? &&
                          other_pricing.effective_date < obj[:schedules].first.closing_date &&
                          other_pricing.expiration_date > obj[:schedules].last.closing_date

              obj[:pricing_ids][other_cargo_class_key] = other_pricing.id
            end
            result_to_return << obj
          end
        end

      end
      result_to_return
    end

    def prep_cargo_units(example)
      data_to_extract = if example[:data][:load_type] == 'cargo_item'
                          example[:data][:cargo_units].map do |cu|
                            cu[:cargo_item_type_id] = CargoItemType.find_by(description: 'Pallet').id
                            cu
                          end
                        else
                          example[:data][:cargo_units]
                        end
      begin
        example[:data][:load_type].camelize.constantize.extract(data_to_extract)
      rescue Exception => e # bad code.....
        raise ApplicationError::BadData
      end
    end

    def prep_faux_schedules(example)
      if !@data_for_price_checker[:service_level]
        tv_ids = {}
        unique_trips = example[:data][:itinerary].trips.select do |trip|
          unless tv_ids[trip.tenant_vehicle_id]
            tv_ids[trip.tenant_vehicle_id] = true
            trip
          end
        end
      else
        unique_trips = [
          example[:data][:itinerary]
            .trips
            .find_by(tenant_vehicle_id: @data_for_price_checker[:service_level].id)
        ].compact
      end
      unique_trips.map do |trip|
        attributes = {
          origin_hub_id: @origin_hub.id,
          destination_hub_id: @destination_hub.id,
          origin_hub_name: @origin_hub.name,
          destination_hub_name: @destination_hub.name,
          mode_of_transport: example[:data][:itinerary].mode_of_transport,
          eta: DateTime.now + 20.days,
          etd: DateTime.now + 10.days,
          closing_date: DateTime.now + 5.days,
          vehicle_name: trip.tenant_vehicle.name,
          trip_id: trip.id
        }
        Legacy::Schedule.new(attributes.merge(id: SecureRandom.uuid))
      end
    end

    def determine_itineraries
      origin_itinerary_ids = @origin_hub.stops.where(index: 0).pluck(:itinerary_id)
      destination_itinerary_ids = @destination_hub.stops.where(index: 1).pluck(:itinerary_id)
      itinerary_ids = origin_itinerary_ids & destination_itinerary_ids
      @tenant.itineraries.where(id: itinerary_ids)
    end

    def determine_trucking_hash(example)
      trucking = { pre_carriage: { truck_type: '' }, on_carriage: { truck_type: '' } }
      if example[:data][:pickup_address]
        trucking[:pre_carriage] = {
          truck_type: example[:data][:origin_truck_type] || 'default',
          address_id: Address.geocoded_address(example[:data][:pickup_address]).id
        }
      end
      if example[:data][:delivery_address]
        trucking[:on_carriage] = {
          truck_type: example[:data][:destination_truck_type] || 'default',
          address_id: Address.geocoded_address(example[:data][:delivery_address]).id
        }
      end
      trucking
    end

    def get_diff_value(result, keys, expected_result)
      value = result.dig(:quote, *keys, :value)
      expected_value = expected_result.dig(*keys, :value).try(:to_d)
      return nil if value.blank? || expected_value.blank?

      (value - expected_value).abs.try(:round, 3)
    end

    def get_diff_percentage(result, keys, expected_result)
      value = result.dig(:quote, *keys, :value)
      expected_value = expected_result.dig(*keys, :value).try(:to_d)
      return nil if (value.blank? || value.zero?) || (expected_value.blank? || expected_value.zero?)

      (((value - expected_value) / expected_value) * 100).try(:round, 3)
    end

    def get_currency(result, keys)
      currency = result.dig(:quote, *keys, :currency)

      return '' if currency.blank?

      currency
    end

    def print_results
      DocumentService::PricingValidationWriter.new(
        data: @validation_results,
        filename: "#{::Tenants::Tenant.find_by(legacy_id: @tenant.id).slug}_pricing_validations",
        tenant_id: @tenant.id
      ).perform
    end

    def convert_value(value, from_currency, to_currency)
      CurrencyTools.new.convert(value, from_currency, to_currency, @tenant.id)
    end

    def diff_result_string(result, keys, expected_result) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      value = result.dig(:quote, *keys, :value)
      expected_value = expected_result.dig(*keys, :value).try(:to_d)
      result_currency = result.dig(:quote, *keys, :currency)
      expected_currency = expected_result.dig(*keys, :currency)
      if (!result_currency.nil? && !expected_currency.nil?) && (result_currency != expected_currency)
        result_value = convert_value(value, result_currency, expected_currency)
        keys.each_with_index do |key, i|
          if i.positive? && keys[i - 1] && (result[:quote][keys[i - 1]][key][:value] = result_value)
            result[:quote][keys[i - 1]][key][:value] = "#{result_value.try(:round, 3)} (#{result_currency} #{value.try(:round, 3)})" # rubocop:disable Metrics/LineLength
            result[:quote][keys[i - 1]][key][:currency] = expected_currency
          end
        end
      else
        result_value = value
      end

      return nil if (result_value.blank? || result_value.zero?) || (expected_value.blank? || expected_value.zero?)

      diff_val = (result_value - expected_value).try(:round, 3)
      diff_percent = ((diff_val / expected_value) * 100).try(:round, 3)

      return nil if diff_val.nil?

      "#{expected_currency} #{diff_val} (#{diff_percent}%)"
    end

    def legacy_charge_shape(result) # rubocop:disable  Metrics/AbcSize
      new_quote = {}
      quote = result[:quote]
      quote.keys.reject { |k| %i[import export].include?(k) }.each { |k| new_quote[k] = quote[k] }
      %i[import export].each do |k|
        next unless quote[k]

        new_quote[k] = { total: { value: 0.0, currency: 'USD' } }
        quote[k].keys.reject { |uk| %i[total edited_total name].include?(uk) }.each do |k_2|
          quote[k][k_2].keys.reject { |uk| %i[total edited_total name].include?(uk) }
                       .each { |k_3| new_quote[k][k_3] = quote[k][k_2][k_3] }
        end
        quote[k].keys.select { |uk| %i[total edited_total name].include?(uk) }.each do |k_2|
          new_quote[k][k_2] = quote[k][k_2]
        end
      end
      result[:quote] = new_quote
      result
    end

    def validate_result(result, expected_result, example_index, data) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      result.deep_symbolize_keys!
      result_for_printing = {}
      result = legacy_charge_shape(result)
      begin
        expected_result.each do |key_1, value_1|
          if value_1 && value_1[:value]
            result_for_printing[key_1] = diff_result_string(result, [key_1], expected_result)
          elsif key_1 == 'cargo'
            value_1[:cargo_item].each do |key_2, _value_2|
              if key_2.to_s != 'edited_total' || key_2.to_s != 'total'
                result_for_printing[key_1] = {} unless result_for_printing[key_1]
                result_for_printing[key_1][key_2] = diff_result_string(result, [key_1, key_2], expected_result)
              end
            end
          elsif value_1 && !value_1.keys.empty?
            value_1.each do |key_2, _value_2|
              if key_2.to_s != 'edited_total' || key_2.to_s != 'total'
                result_for_printing[key_1] = {} unless result_for_printing[key_1]
                result_for_printing[key_1][key_2] = diff_result_string(result, [key_1, key_2], expected_result)
              end
            end
          end
        end
      rescue StandardError => e
        Rails.logger.error e.message
      end

      {
        result: result,
        expected: expected_result,
        number: example_index,
        diff: result_for_printing,
        data: data
      }
    end

    def validate_prices(sheet_name, itinerary, data_for_price_checker, expected_results, example_index, data) # rubocop:disable Metrics/ParameterLists
      results = itinerary.test_pricings(data_for_price_checker, @user)
      @validation_results[sheet_name] = {} unless @validation_results[sheet_name]
      @validation_results[sheet_name][example_index] = validate_result(results.first, expected_results, example_index, data)
    end

    def sort_pricings(schedules:, user_pricing_id:, cargo_classes:, dates:, dedicated_pricings_only:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if @scope['base_pricing']
        return ::Pricings::Finder.new(
          schedules: schedules,
          user_pricing_id: user_pricing_id,
          cargo_classes: cargo_classes,
          dates: dates,
          dedicated_pricings_only: dedicated_pricings_only,
          shipment: @shipment,
          sandbox: nil
        ).perform
      end
      tenant_vehicle_id = schedules.first.trip.tenant_vehicle_id
      start_date = dates[:start_date]
      end_date = dates[:end_date]
      closing_start_date = dates[:closing_start_date]
      closing_end_date = dates[:closing_end_date]
      pricings_by_cargo_class = schedules.first.trip.itinerary.pricings
                                         .where(tenant_vehicle_id: tenant_vehicle_id)
                                         .for_cargo_classes(cargo_classes)
      if start_date && end_date
        pricings_by_cargo_class_and_dates = pricings_by_cargo_class.for_dates(start_date, end_date)
      end
      ## If etd filter results in no pricings, check using closing_date
      if start_date && end_date && pricings_by_cargo_class_and_dates.empty?
        pricings_by_cargo_class_and_dates = pricings_by_cargo_class
                                            .for_dates(closing_start_date, closing_end_date)
      end

      pricings_by_cargo_class_and_dates_and_user = pricings_by_cargo_class_and_dates
                                                   .select { |pricing| pricing.user_id == user_pricing_id }
      if pricings_by_cargo_class_and_dates_and_user.empty? && !dedicated_pricings_only
        pricings_by_cargo_class_and_dates_and_user = pricings_by_cargo_class_and_dates
                                                     .select { |pricing| pricing.user_id.nil? }
      end
      pricings_by_cargo_class_and_dates_and_user.group_by { |pricing| pricing.transport_category_id.to_s }
    end

    def dedicated_pricings?(user)
      if @scope['base_pricing']
        @scope['dedicated_pricings_only']
      else
        user.pricings.exists? && @scope['dedicated_pricings_only']
      end
    end

    def extract_dates_and_quote(schedules)
      if schedules&.any? { |s| s.etd.nil? || s.eta.nil? }
        is_quote = true
        start_date = Date.today
        end_date = start_date + 1.month
        closing_start_date = start_date - 5.days
        closing_end_date = end_date - 5.days
      else
        start_date = schedules.first.etd
        end_date = schedules.last.etd
        closing_start_date = schedules.first.closing_date
        closing_end_date = schedules.last.closing_date
        is_quote = false
      end
      {
        start_date: start_date,
        end_date: end_date,
        is_quote: is_quote,
        closing_start_date: closing_start_date,
        closing_end_date: closing_end_date
      }
    end
  end
end
