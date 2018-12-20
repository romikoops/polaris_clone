# frozen_string_literal: true

module DataValidator
  class PricingValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object
    include OfferCalculatorService
    include AwsConfig
    include CurrencyTools
    include DocumentService

    def post_initialize(args)
      signed_url = get_file_url(args[:key], 'assets.itsmycargo.com')
      @xlsx = open_file(signed_url)
      @shipment_ids_to_destroy = []
      @user = args[:user] ||= @tenant.users.shipper.first
      @dummy_data = args[:data]
      @validation_results = {}
      @row_keys = {}
      @cargo_unit_keys = []
      @fee_keys = {}
      @examples = []
      @sheet_rows = []
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

    def create_example_results
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
          new_cargo[key] = column[value]
        end
        cargos << new_cargo
      end
      cargos
    end

    def get_top_value_currency(column, key)
      str = column[@row_keys[key]]
      to_display = string_to_currency_value(str)
      if to_display.nil?
        return {}
      elsif key == 'TOTAL'
        return to_display
      else
        return { total: to_display }
      end
    end

    def price_check(example, sheet_name)
      @destination_hub = example[:data][:itinerary].last_stop.hub
      @origin_hub = example[:data][:itinerary].first_stop.hub
      @shipment = Shipment.create!(
        user: @user,
        tenant: @tenant,
        load_type: example[:data][:load_type],
        planned_pickup_date: DateTime.now + 2.weeks,
        origin_hub: @origin_hub,
        destination_hub: @destination_hub,
        trucking: determine_trucking_hash(example)
      )
      @shipment_ids_to_destroy << @shipment.id
      @shipment.cargo_units = prep_cargo_units(example)
      @hubs = { origin: [@origin_hub], destination: [@destination_hub] }
      @trucking_data_builder = OfferCalculatorService::TruckingDataBuilder.new(@shipment)
      @trucking_data = @trucking_data_builder.perform(@hubs)
      @data_for_price_checker = @example[:data]
      @data_for_price_checker[:trucking] = @trucking_data
      @data_for_price_checker[:has_on_carriage] = example[:data][:delivery_address]
      @data_for_price_checker[:has_pre_carriage] = example[:data][:pickup_address]
      @data_for_price_checker[:service_level] = @tenant.tenant_vehicles.find_by(
        name: example[:data][:service_level],
        carrier: Carrier.find_by_name(example[:data][:carrier]),
        mode_of_transport: @example[:data][:mode_of_transport]
      )
      @data_for_price_checker[:cargo_units] = example[:data][:cargo_units]
      validate_prices(sheet_name, example[:data][:itinerary], @data_for_price_checker, example[:expected], example[:result_index], example[:data])
    end

    def prep_cargo_units(example)
      data_to_extract = example[:data][:load_type] == 'cargo_item' ?
        example[:data][:cargo_units].map do |cu|
          cu[:cargo_item_type_id] = CargoItemType.find_by_description('Pallet').id
          cu
        end : example[:data][:cargo_units]
      begin
        example[:data][:load_type].camelize.constantize.extract(data_to_extract)
      rescue Exception => e # bad code.....
        raise ApplicationError::BadData
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
      return nil if (value.blank? || value == 0) || (expected_value.blank? || expected_value == 0)
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
        filename: "#{@tenant.subdomain}_pricing_validations",
        tenant_id: @tenant.id
      ).perform
    end

    def convert_value(value, from_currency, to_currency)
      CurrencyTools.convert(value, from_currency, to_currency, @tenant.id)
    end

    def diff_result_string(result, keys, expected_result)
      value = result.dig(:quote, *keys, :value)
      expected_value = expected_result.dig(*keys, :value).try(:to_d)
      result_currency = result.dig(:quote, *keys, :currency)
      expected_currency = expected_result.dig(*keys, :currency)
      if (!result_currency.nil? && !expected_currency.nil?) && (result_currency != expected_currency)
        result_value = convert_value(value, result_currency, expected_currency)
        keys.each_with_index do |key, i|
          if i > 0 && keys[i - 1] && result[:quote][keys[i - 1]][key][:value] = result_value
            result[:quote][keys[i - 1]][key][:value] = "#{result_value.try(:round, 3)} (#{result_currency} #{value.try(:round, 3)})"
            result[:quote][keys[i - 1]][key][:currency] = expected_currency
          end
        end
      else
        result_value = value
      end

      return nil if (result_value.blank? || result_value == 0) || (expected_value.blank? || expected_value == 0)

      diff_val = (result_value - expected_value).try(:round, 3)
      diff_percent = ((diff_val / expected_value) * 100).try(:round, 3)

      return nil if diff_val.nil?
      "#{expected_currency} #{diff_val} (#{diff_percent}%)"
    end

    def validate_result(result, expected_result, example_index, data)
      result.deep_symbolize_keys!
      result_for_printing = {}
      begin
      expected_result.each do |key1, value1|
        if value1 && value1[:value]
          result_for_printing[key1] = diff_result_string(result, [key1], expected_result)
        elsif key1 == 'cargo'
          value1[:cargo_item].each do |key2, _value2|
            if key2.to_s != 'edited_total' || key2.to_s != 'total'
              result_for_printing[key1] = {} unless result_for_printing[key1]
              result_for_printing[key1][key2] = diff_result_string(result, [key1, key2], expected_result)
            end
          end
        elsif value1 && !value1.keys.empty?
          value1.each do |key2, _value2|
            if key2.to_s != 'edited_total' || key2.to_s != 'total'
              result_for_printing[key1] = {} unless result_for_printing[key1]
              result_for_printing[key1][key2] = diff_result_string(result, [key1, key2], expected_result)
            end
          end
        end
      end
    rescue Exception => e
     
    end
      final_result = {
        result: result,
        expected: expected_result,
        number: example_index,
        diff: result_for_printing,
        data: data
      }
    end

    def validate_prices(sheet_name, itinerary, data_for_price_checker, expected_results, example_index, data)
      results = itinerary.test_pricings(data_for_price_checker, @user)
      @validation_results[sheet_name] = {} unless @validation_results[sheet_name]
      @validation_results[sheet_name][example_index] = validate_result(results.first, expected_results, example_index, data)
    end
  end
end
