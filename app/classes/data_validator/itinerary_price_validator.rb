# frozen_string_literal: true

module DataValidator
  class ItineraryPriceValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object

    def post_initialize(args)
      itinerary_ids = @tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id).for_load_type(args[:load_type]).empty?
      end
      @itineraries = @tenant.itineraries.where(id: itinerary_ids)
      @user = @user ||= tenant.users.shipper.first
      @dummy_data = args[:load_type] == 'cargo_item' ? {
        has_pre_carriage: args[:has_pre_carriage],
        has_on_carriage: args[:has_on_carriage],
        export: args[:export],
        import: args[:import],
        cargo_units: [
          {
            dimension_x: 120,
            dimension_y: 80,
            dimension_z: 120,
            quantity: 1,
            payload_in_kg: 1000
          }
        ],
        load_type: 'cargo_item'
      } :
      {
        has_pre_carriage: args[:has_pre_carriage],
        has_on_carriage: args[:has_on_carriage],
        export: args[:export],
        import: args[:import],
        cargo_units: [
          {
            size_class: 'fcl_20',
            payload_in_kg: 10_000,
            payload_in_kg: 1000
          }
        ],
        load_type: 'container'
      }
      default_expected_values = {
        has_pre_carriage: args[:has_pre_carriage],
        has_on_carriage: args[:has_on_carriage],
        export: args[:export],
        import: args[:import],
        cargo: true
      }
      @expected_values = args[:expected_values] || default_expected_values
      @validation_results = {}
    end

    def perform
      validate_prices
    end

    private

    def validate_prices # rubocop:disable Metrics/AbcSize
      @itineraries.each do |itinerary|
        @validation_results[itinerary.id] = [] unless @validation_results[itinerary.id]
        results = itinerary.test_pricings(@dummy_data, @user)
        results.each do |result|
          invalid_keys = []
          result.deep_symbolize_keys!
          %i(export import cargo).each do |target|
            invalid_keys.push(target) if !result[:quote][target] && @expected_values[target]
          end
          if !invalid_keys.empty?
            @validation_results[itinerary.id] << "Itinerary #{itinerary.id} level: #{result[:service_level].name} is missing: #{invalid_keys.map(&:to_s).join(', ')} " # rubocop:disable Metrics/LineLength
          else
            @validation_results[itinerary.id] << "Itinerary #{itinerary.id} level: #{result[:service_level].name} is valid!" # rubocop:disable Metrics/LineLength
          end
        end
      end
    end
  end
end
