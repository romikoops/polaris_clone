# frozen_string_literal: true

module DataValidator
  class PricingValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object
    include OfferCalculatorService
    include AwsConfig
    include DocumentService

    def post_initialize(args)
      signed_url = get_file_url(args[:key], 'assets.itsmycargo.com')
      @json_array = JSON.parse(open(signed_url).read).deep_symbolize_keys!
      @shipment_ids_to_destroy = []
      @user = args[:user] ||= @tenant.users.shipper.first
      @dummy_data = args[:data]
      @validation_results = {}
    end

    def perform
      @json_array.each do |_origin, json_data|
        @json_data = json_data
        @load_type = @json_data[:metadata][:load_type]
        @origin_hub = @tenant.hubs.find_by_name(@json_data[:metadata][:origin_hub])
        @json_data[:expected_values].each do |destination_key, results|
          results.each_with_index do |expected_result, i|
            price_check(destination_key, expected_result, i)
          end
        end
      end
      Shipment.where(id: @shipment_ids_to_destroy).destroy_all
      print_results
    end

    private

    def price_check(destination_key, expected_result, example_index)
      example_data = @json_data[:examples][example_index]
      @destination_hub = @tenant.hubs.find_by_name("#{destination_key} Port")
      @shipment = Shipment.create!(
        user: @user,
        tenant: @tenant,
        load_type: @load_type,
        destination_hub: @destination_hub,
        trucking: determine_trucking_hash(example_data)
      )
      @shipment_ids_to_destroy << @shipment.id
      @shipment.cargo_units = prep_cargo_units(example_data)
      @hubs = { origin: [@origin_hub], destination: [@destination_hub] }
      @trucking_data_builder = OfferCalculatorService::TruckingDataBuilder.new(@shipment)
      @trucking_data = @trucking_data_builder.perform(@hubs)
      @itineraries = determine_itineraries
      @data_for_price_checker = @json_data[:metadata]
      @data_for_price_checker[:trucking] = @trucking_data
      @data_for_price_checker[:cargo_units] = example_data[:cargo_units]
      validate_prices(@itineraries, @data_for_price_checker, expected_result, example_index)
    end

    def prep_cargo_units(example_data)
      data_to_extract = @load_type == 'cargo_item' ?
        example_data[:cargo_units].map do |cu|
          cu[:cargo_item_type_id] = CargoItemType.find_by_description('Pallet').id
          cu
        end : example_data[:cargo_units]
      @load_type.camelize.constantize.extract(data_to_extract)
    end

    def determine_itineraries
      origin_itinerary_ids = @origin_hub.stops.where(index: 0).pluck(:itinerary_id)
      destination_itinerary_ids = @destination_hub.stops.where(index: 1).pluck(:itinerary_id)
      itinerary_ids = origin_itinerary_ids & destination_itinerary_ids
      @tenant.itineraries.where(id: itinerary_ids)
    end

    def determine_trucking_hash(example_data)
      trucking = { pre_carriage: { truck_type: '' }, on_carriage: { truck_type: '' } }
      if @json_data[:metadata][:has_pre_carriage]
        trucking[:pre_carriage] = {
          truck_type: @load_type === 'cargo_item' ? 'default' : 'chassis',
          location_id: Location.geocoded_location(example_data[:pickup_address]).id
        }
      end
      if @json_data[:metadata][:has_on_carriage]
        trucking[:on_carriage] = {
          truck_type: @load_type === 'cargo_item' ? 'default' : 'chassis',
          location_id: Location.geocoded_location(example_data[:delivery_address]).id
        }
      end
      trucking
    end

    def get_diff_value(result, key, expected_result)
      value = result.dig(:quote, key.to_sym, :total, :value)
      return nil if value.nil? || expected_result[key.to_sym] < 1

      (value - expected_result[key.to_sym]).abs
    end

    def get_diff_percentage(result, key, expected_result)
      value = result.dig(:quote, key.to_sym, :total, :value)
      return nil if value.nil? || expected_result[key.to_sym] < 1

      ((value - expected_result[key.to_sym]) / expected_result[key.to_sym]) * 100
    end

    def print_results
      DocumentService::PricingValidationWriter.new(
        data: @validation_results,
        filename: "#{@tenant.subdomain}_pricing_validations",
        tenant_id: @tenant.id
      ).perform
    end

    def validate_result(results, expected_result, example_index)
      result_comparisons = {
        exact: [],
        close: [],
        all: []
      }
      results.each do |result|
        result.deep_symbolize_keys!
        result_comparisons[:all] << {
          example_number: example_index + 1,
          itinerary: result[:itinerary],
          diff_val: get_diff_value(result, :total, expected_result),
          diff_percent: get_diff_percentage(result, :total, expected_result),
          trucking_pre_diff_val: get_diff_value(result, :trucking_pre, expected_result),
          trucking_pre_diff_percent: get_diff_percentage(result, :trucking_pre, expected_result),
          trucking_on_diff_val: get_diff_value(result, :trucking_on, expected_result),
          trucking_on_diff_percent: get_diff_percentage(result, :trucking_on, expected_result),
          service_level: result[:service_level],
          expected_total: expected_result[:total],
          expected_import: expected_result[:import],
          expected_export: expected_result[:export],
          import: result.dig(:quote, :import, :total, :value),
          export: result.dig(:quote, :export, :total, :value),
          import_diff_val: get_diff_value(result, :import, expected_result),
          import_diff_percent: get_diff_percentage(result, :import, expected_result),
          export_diff_val: get_diff_value(result, :export, expected_result),
          export_diff_percent: get_diff_percentage(result, :export, expected_result),
          expected_trucking_pre: expected_result[:trucking_pre],
          expected_trucking_on: expected_result[:trucking_on],
          total: result.dig(:quote, :total, :value),
          trucking_pre: result.dig(:quote, :trucking_pre, :total, :value),
          trucking_on: result.dig(:quote, :trucking_on, :total, :value)
        }
      end
      result_comparisons
    end

    def validate_prices(itineraries, data_for_price_checker, expected_results, example_index)
      itineraries.each do |itinerary|
        results = itinerary.test_pricings(data_for_price_checker, @user)
        @validation_results[itinerary.id] = {} unless @validation_results[itinerary.id]
        @validation_results[itinerary.id][example_index] = validate_result(results, expected_results, example_index)
      end
    end
  end
end
