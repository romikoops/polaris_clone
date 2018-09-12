module DataValidator
  class SpeedtransPricingValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object
    include OfferCalculatorService
    include AwsConfig

    def post_initialize(args)
      signed_url = get_file_url('data/speedtrans/speedtrans_pricing_data.json', "assets.itsmycargo.com")
      @json_data = JSON.parse(open(signed_url).read).deep_symbolize_keys!
      @shipment_ids_to_destroy = []
      @load_type = @json_data[:metadata][:load_type]
      @origin_hub = @tenant.hubs.find_by_name(@json_data[:metadata][:origin_hub])
      @user = args[:user] ||= @tenant.users.shipper.first
      @dummy_data = args[:data]
      @validation_results = {}
    end

    def perform
      @json_data[:expected_values].each do |destination_key, results|
        results.each_with_index do |expected_result, i|
          price_check(destination_key, expected_result, i)
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
      @shipment.cargo_items = prep_cargo_units(example_data)
      @hubs = {origin: [@origin_hub], destination: [@destination_hub]}
      @trucking_data_builder      = OfferCalculatorService::TruckingDataBuilder.new(@shipment)
      @trucking_data      = @trucking_data_builder.perform(@hubs)
      @itineraries = determine_itineraries
      @data_for_price_checker = @json_data[:metadata]
      @data_for_price_checker[:trucking] = @trucking_data
      @data_for_price_checker[:cargo_units] = example_data[:cargo_units]
      validate_prices(@itineraries, @data_for_price_checker, expected_result, example_index)
    end

    def prep_cargo_units(example_data)
      data_to_extract = @load_type == 'cargo_item' ? 
        example_data[:cargo_units].map do |cu|
          cu[:cargo_item_type_id] = CargoItemType.find_by_description("Pallet").id
          cu
        end : example_data[:cargo_units]
      @load_type.camelize.constantize.extract(data_to_extract)
    end

    def determine_itineraries
      origin_itinerary_ids = @origin_hub.stops.pluck(:itinerary_id)
      destination_itinerary_ids = @destination_hub.stops.pluck(:itinerary_id)
      itinerary_ids = origin_itinerary_ids & destination_itinerary_ids
      @tenant.itineraries.where(id: itinerary_ids)
    end

    def determine_trucking_hash(example_data)
      trucking = { pre_carriage: {truck_type: ''}, on_carriage: {truck_type: ''}}
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

    def print_results
      @validation_results.each do |itinerary_id, results|
        results.each do |example_index, result|
          if result[:exact].empty?
            result_to_render = result[:close].first
            awesome_print "#{result_to_render[:itinerary][:name]}, example #{example_index} is incorrect.
                Service Level: #{result_to_render[:service_level].name}
                Total: #{result_to_render[:expected_total]}, got: #{result_to_render[:total]}}
                Trucking: #{result_to_render[:expected_trucking]}, got: #{result_to_render[:trucking]}}
                Closest Diff: #{result_to_render[:diff_percent].round(4)}% \n
                Trucking Diff: #{result_to_render[:trucking_diff_percent].round(4)}%"
          else
            result_string = "#{result[:exact].first[:itinerary][:name]}:"
            result[:exact].each do |result_to_render|
              result_string += "\n example #{example_index} is correct.
                Total: #{result_to_render[:expected_total]}, got: #{result_to_render[:total]}}
                Trucking: #{result_to_render[:expected_trucking]}, got: #{result_to_render[:trucking]}}
                Service Level: #{result_to_render[:service_level].name}
                Diff: #{result_to_render[:diff_percent].round(4)}% 
                Trucking Diff: #{result_to_render[:trucking_diff_percent].round(4)}%"
            end
            puts result_string
          end
        end

      end
    end

    def validate_result(results, expected_result)
      result_comparisons = {
        exact: [],
        close: []
      }
      results.each do |result|
        result.deep_symbolize_keys!
        if (result[:quote][:total][:value] - expected_result[:total]).abs < 1
          result_comparisons[:exact] << {
            itinerary: result[:itinerary],
            diff_val:  (result[:quote][:total][:value] - expected_result[:total]).abs,
            diff_percent:  ((result[:quote][:total][:value] - expected_result[:total])/expected_result[:total]) * 100,
            trucking_diff_val:  (result[:quote][:trucking_pre][:total][:value] - expected_result[:trucking]).abs,
            trucking_diff_percent:  ((result[:quote][:trucking_pre][:total][:value] - expected_result[:trucking])/expected_result[:trucking]) * 100,
            service_level: result[:service_level],
            expected_total: expected_result[:total],
            expected_trucking: expected_result[:trucking],
            total: result[:quote][:total][:value],
            trucking: result[:quote][:trucking_pre][:value],
          }
        else
          result_comparisons[:close] << {
            itinerary: result[:itinerary],
            diff_val:  (result[:quote][:total][:value] - expected_result[:total]).abs,
            diff_percent:  ((result[:quote][:total][:value] - expected_result[:total])/expected_result[:total]) * 100,
            trucking_diff_val:  (result[:quote][:trucking_pre][:total][:value] - expected_result[:trucking]).abs,
            trucking_diff_percent:  ((result[:quote][:trucking_pre][:total][:value] - expected_result[:trucking])/expected_result[:trucking]) * 100,
            service_level: result[:service_level],
            expected_total: expected_result[:total],
            expected_trucking: expected_result[:trucking],
            total: result[:quote][:total][:value],
            trucking: result[:quote][:trucking_pre][:value],
          }
        end
      end
      result_comparisons
    end

    def validate_prices(itineraries, data_for_price_checker, expected_results, example_index)
      itineraries.each do |itinerary|
        results = itinerary.test_pricings(data_for_price_checker, @user)
        @validation_results[itinerary.id] = {} unless @validation_results[itinerary.id]
        @validation_results[itinerary.id][example_index] = validate_result(results, expected_results)
      end
    end
  end
end
