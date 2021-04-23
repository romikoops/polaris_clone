# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      class Trucking < ExcelDataServices::DataFrames::Coordinators::Base
        def restructured_data
          complete_truckings[insert_keys]
        end

        def complete_truckings
          @complete_truckings ||= rates_locations_and_metadata
            .inner_join(default_fees_frame, on: "hub_id")
            .left_join(fees.frame, on: { "truck_type" => "truck_type", "carriage" => "carriage" })
        end

        def rates_locations_and_metadata
          @rates_locations_and_metadata ||= metadata.frame
            .inner_join(rates.frame, on: { "cargo_class" => "cargo_class", "carriage" => "carriage", "truck_type" => "truck_type" })
            .inner_join(locations.frame, on: { "zone" => "zone" })
        end

        def combinator_errors
          @combinator_errors ||= [metadata, fees, rates, locations].sum(&:errors)
        end

        def fees
          @fees ||= ExcelDataServices::DataFrames::Coordinators::Truckings::Fees.state(state: coordinator_state)
        end

        def rates
          @rates ||= ExcelDataServices::DataFrames::Coordinators::Truckings::Rates.state(state: coordinator_state)
        end

        def metadata
          @metadata ||= ExcelDataServices::DataFrames::Coordinators::Truckings::Metadata.state(state: coordinator_state)
        end

        def locations
          @locations ||= ExcelDataServices::DataFrames::Coordinators::Truckings::Locations.state(
            state: coordinator_state
          )
        end

        def insert_keys
          default_keys + %w[fees rates location_id]
        end

        def default_keys
          %w[
            cbm_ratio
            group_id
            modifier
            hub_id
            organization_id
            identifier_modifier
            carriage
            cargo_class
            load_type
            tenant_vehicle_id
            truck_type
            validity
          ]
        end

        def default_fees_frame
          Rover::DataFrame.new([{ "fees" => {}, "hub_id" => state.hub_id }])
        end
      end
    end
  end
end
