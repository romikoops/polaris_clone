# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Trucking < ExcelDataServices::V4::Formatters::Base
        VERSION_KEYS = %w[organization_id hub_id trucking_location_id truck_type carriage cargo_class tenant_vehicle_id].freeze
        MODEL_ATTR_KEYS = %w[
          cargo_class
          carriage
          cbm_ratio
          load_type
          truck_type
          group_id
          hub_id
          organization_id
          tenant_vehicle_id
          zone
          fees
          rates
          target
          secondary
          validity
          location_id
          modifier
          load_meterage
        ].freeze

        def insertable_data
          combined_frame[MODEL_ATTR_KEYS].to_a
        end

        def combined_frame
          @combined_frame ||= formatted_rates_and_fees.left_join(zone_frame, on: { "zone" => "zone" }).tap do |tapped_frame|
            tapped_frame["target"] = tapped_frame[target_from_identifier]
            tapped_frame["secondary"] = tapped_frame[secondary_from_identifier]
            tapped_frame["location_id"] = tapped_frame["trucking_location_id"]
          end
        end

        def formatted_rates_and_fees
          @formatted_rates_and_fees ||= ExcelDataServices::V4::Helpers::FeeExpansion.new(
            rates_and_metadata: formatted_rates_and_metadata,
            formatted_fees: formatted_fees
          ).perform
        end

        def formatted_rates_and_metadata
          @formatted_rates_and_metadata ||= metadata_with_load_meterage_and_modifiers
            .left_join(formatted_rates, on: { "sheet_name" => "sheet_name", "organization_id" => "organization_id" })
        end

        def formatted_rates
          @formatted_rates ||= ExcelDataServices::V4::Formatters::TruckingRates.new(
            data_frame: rates_with_currency
          ).rates
        end

        def formatted_fees
          @formatted_fees ||= ExcelDataServices::V4::Formatters::TruckingFees.new(
            data_frame: fees_frame,
            rate_versions: rate_versions
          ).fees
        end

        def metadata_with_load_meterage_and_modifiers
          @metadata_with_load_meterage_and_modifiers ||= metadata_frame
            .inner_join(load_meterage_frame, on: { "sheet_name" => "sheet_name", "organization_id" => "organization_id" })
            .inner_join(modifiers, on: { "sheet_name" => "sheet_name", "organization_id" => "organization_id" })
        end

        def zone_frame
          @zone_frame ||= state.frame("zones")[%w[zone postal_code locode distance city province range trucking_location_id identifier]]
        end

        def rates_frame
          @rates_frame ||= state.frame("rates")
        end

        def rates_with_currency
          @rates_with_currency ||= rates_frame.left_join(metadata_frame[%w[sheet_name currency]], on: { "sheet_name" => "sheet_name" })
        end

        def fees_frame
          @fees_frame ||= state.frame("fees")
        end

        def metadata_frame
          @metadata_frame ||= state.frame("default")
        end

        def rate_versions
          @rate_versions ||= metadata_frame[%w[service carrier carriage cargo_class truck_type sheet_name organization_id]]
        end

        def modifiers
          @modifiers ||= rates_frame[%w[modifier sheet_name organization_id]].uniq
        end

        def load_meterage_frame
          @load_meterage_frame ||= ExcelDataServices::V4::Formatters::LoadMeterage.new(frame: metadata_frame).load_meterage
        end

        def target_from_identifier
          case identifier
          when "postal_city", "postal_code"
            "postal_code"
          else
            identifier
          end
        end

        def secondary_from_identifier
          case identifier
          when "postal_city"
            "city"
          when "city"
            "province"
          else
            "range"
          end
        end

        def identifier
          @identifier ||= zone_frame.first_row["identifier"]
        end
      end
    end
  end
end
