# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Helpers
      class FeeExpansion
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze
        METADATA_COLUMNS = %w[
          cbm_ratio
          truck_type
          load_type
          cargo_class
          carriage
          carrier
          carrier_code
          service
          effective_date
          expiration_date
          organization_id
        ].freeze
        RATE_VERSION_KEYS = %w[
          truck_type
          cargo_class
          carriage
          tenant_vehicle_id
          carrier_id
          zone
          organization_id
        ].freeze
        FEE_VERSION_KEYS = %w[cargo_class zone service carrier organization_id].freeze

        def initialize(formatted_fees:, rates_and_metadata:)
          @formatted_fees = formatted_fees
          @rates_and_metadata = rates_and_metadata
        end

        def perform
          expanded_unzoned_rates_and_fees.concat(zoned_expanded_rates_and_fees)
        end

        attr_reader :formatted_fees, :rates_and_metadata

        private

        def zoned_formatted_fees
          @zoned_formatted_fees ||= formatted_fees[!formatted_fees["zone"].missing]
        end

        def unzoned_formatted_fees
          @unzoned_formatted_fees ||= formatted_fees[formatted_fees["zone"].missing]
        end

        def expanded_zoned_rates_and_fees
          @expanded_zoned_rates_and_fees ||= rates_and_metadata.left_join(zoned_formatted_fees, on: {
            "truck_type" => "truck_type",
            "cargo_class" => "cargo_class",
            "carriage" => "carriage",
            "carrier" => "carrier",
            "service" => "service",
            "zone" => "zone",
            "organization_id" => "organization_id"
          })
        end

        def zoned_expanded_rates_and_fees
          @zoned_expanded_rates_and_fees ||= expanded_zoned_rates_and_fees[!expanded_zoned_rates_and_fees["fees"].missing]
        end

        def unzoned_expanded_rates_and_fees
          @unzoned_expanded_rates_and_fees ||= expanded_zoned_rates_and_fees[expanded_zoned_rates_and_fees["fees"].missing]
        end

        def expanded_unzoned_rates_and_fees
          @expanded_unzoned_rates_and_fees ||= unzoned_expanded_rates_and_fees.left_join(unzoned_formatted_fees, on: {
            "truck_type" => "truck_type",
            "cargo_class" => "cargo_class",
            "carriage" => "carriage",
            "carrier" => "carrier",
            "service" => "service",
            "organization_id" => "organization_id"
          })
        end
      end
    end
  end
end
