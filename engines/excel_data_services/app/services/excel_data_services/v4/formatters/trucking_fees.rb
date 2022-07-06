# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TruckingFees
        FILTER_KEYS = %w[zone cargo_class carrier service].freeze
        MAIN_KEYS = %w[organization_id truck_type carriage].freeze
        VERSION_KEYS = (MAIN_KEYS + FILTER_KEYS).freeze

        def initialize(data_frame:, rate_versions:)
          @data_frame = data_frame
          @rate_versions = rate_versions
        end

        def fees
          rate_versions.to_a.inject(blank_data_frame) do |accumulator, rate_version|
            accumulator.concat(FeesForRateVersion.new(rate_version: rate_version.slice(*VERSION_KEYS), data_frame: formatted_fees.filter(rate_version.slice(*MAIN_KEYS))).perform)
          end
        end

        private

        attr_reader :data_frame, :rate_versions

        def formatted_fees
          @formatted_fees ||= Rover::DataFrame.new(
            data_frame.to_a.map do |fee_row|
              variant = fee_row.slice(*valid_filter_keys)
              variant.merge("fee" => JsonFeeStructure.new(frame: data_frame.filter(variant)).perform)
            end
          )
        end

        def valid_filter_keys
          VERSION_KEYS & data_frame.keys
        end

        def blank_data_frame
          Rover::DataFrame.new(desired_data_frame_keys.zip([] * desired_data_frame_keys.size).to_h)
        end

        def desired_data_frame_keys
          @desired_data_frame_keys ||= VERSION_KEYS + ["fees"]
        end

        class FeesForRateVersion
          def initialize(data_frame:, rate_version:)
            @data_frame = data_frame
            @rate_version = rate_version
          end

          attr_reader :data_frame, :rate_version

          def perform
            Rover::DataFrame.new(data_for_frame)
          end

          private

          def data_for_frame
            if data_frame.empty?
              [base_fees_variant]
            else
              unzoned_fees_for_rate_version + zoned_fees_for_rate_version
            end
          end

          def unzoned_fees_for_rate_version
            [base_fees_variant.merge("fees" => formatted_unzoned_fees_for_rate_version)]
          end

          def zones
            @zones ||= data_frame["zone"].to_a.uniq.compact
          end

          def formatted_unzoned_fees_for_rate_version
            @formatted_unzoned_fees_for_rate_version ||= FormattedFee.new(data_frame: data_frame[data_frame["zone"].missing], rate_version: rate_version).perform
          end

          def zoned_fees_for_rate_version
            @zoned_fees_for_rate_version ||= zones.map do |zone|
              merged_fees = formatted_unzoned_fees_for_rate_version.merge(FormattedFee.new(data_frame: data_frame.filter("zone" => zone), rate_version: rate_version).perform)
              rate_version.merge(
                "fees" => merged_fees,
                "zone" => zone
              )
            end
          end

          def base_fees_variant
            rate_version.merge("fees" => {}, "zone" => nil)
          end
        end

        class FormattedFee
          FILTER_KEYS = %w[cargo_class carrier service].freeze

          def initialize(data_frame:, rate_version:)
            @data_frame = data_frame
            @rate_version = rate_version
          end

          def perform
            fees_in_order_of_preference.inject({}) do |accumulator, fee|
              accumulator.merge(fee)
            end
          end

          attr_reader :data_frame, :rate_version

          def fees_in_order_of_preference
            [
              default_fees,
              fees_matching_cargo_class,
              fees_matching_carrier,
              fees_matching_service
            ].flatten
          end

          def default_fees
            @default_fees ||= data_frame.filter(FILTER_KEYS.zip([nil] * FILTER_KEYS.size).to_h)["fee"].to_a
          end

          def fees_matching_cargo_class
            @fees_matching_cargo_class ||= data_frame.filter(rate_version.slice("cargo_class"))["fee"].to_a
          end

          def fees_matching_service
            @fees_matching_service ||= data_frame.filter(rate_version.slice("service", "carrier"))["fee"].to_a
          end

          def fees_matching_carrier
            @fees_matching_carrier ||= data_frame[data_frame["service"].missing].filter(rate_version.slice("carrier"))["fee"].to_a
          end
        end
      end
    end
  end
end
