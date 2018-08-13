module DataValidator
  class ItineraryPriceValidator < DataValidator::BaseValidator
    attr_reader :path, :user, :port_object

    def post_initialize(args)
      itinerary_ids = @tenant.itineraries.ids.reject do |id|
        Pricing.where(itinerary_id: id).for_load_type('cargo_item').empty?
      end
      @itineraries = @tenant.itineraries.where(id: itinerary_ids)
      @user = @user ||= tenant.users.shipper.first
      @dummy_data = {
        has_pre_carriage: false,
        has_on_carriage: false,
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
      }
      default_expected_values = {
        export: true,
        import: false,
        cargo: true
      }
      @expected_values = args[:expected_values] || default_expected_values
      @validation_results = {}
    end

    def perform
      validate_prices
    end

    private
    def validate_prices
      @itineraries.each do |itinerary|
        @validation_results[itinerary.id] = [] unless @validation_results[itinerary.id]
        results = itinerary.test_pricings(@dummy_data, @user)
        results.each do |result|

          invalid_keys = []
          result.deep_symbolize_keys!
          [:export, :import, :cargo].each do |target|

            if (!result[:quote][target] && @expected_values[target])
              invalid_keys.push(target)
            end
          end
          if invalid_keys.length > 0
            @validation_results[itinerary.id] << "Itinerary #{itinerary.id} level: #{result[:service_level].name } is missing: #{invalid_keys.map{|key| key.to_s}.join(', ')} "
          else
            
            @validation_results[itinerary.id] << "Itinerary #{itinerary.id} level: #{result[:service_level].name } is valid!"
          end
        end
      end
      awesome_print @validation_results
    end
  end
end
