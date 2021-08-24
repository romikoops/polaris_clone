# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Operations
      class DynamicFees < ExcelDataServices::V2::Operations::Base
        # This class handles our dynamic fee columns sheets. It isolates any columns outside of the defined sheet columns and creates a row in the data frame for each fee cell
        PRICING_COLUMNS = %w[group_id group_name effective_date expiration_date country_origin service_level origin origin_locode country_destination mode_of_transport destination destination_locode transshipment transit_time carrier service load_type cargo_class rate currency rate_basis fee_code fee_name fee_min fee wm_ratio vm_ratio range_max range_min remarks].freeze
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze

        def perform
          return state if dynamic_keys.empty?

          super
        end

        def operation_result
          Rover::DataFrame.new(adjusted_frame[!adjusted_frame["fee_code"].missing].to_a.uniq, types: frame.types)
        end

        def adjusted_frame
          @adjusted_frame ||= dynamic_keys.each_with_object(frame) do |dynamic_key, inner_frame|
            FrameAdjustment.new(dynamic_key: dynamic_key, inner_frame: inner_frame).perform
          end
        end

        def dynamic_keys
          frame.keys - PRICING_COLUMNS - STATE_COLUMNS
        end

        def existing_columns
          frame.keys - dynamic_keys
        end

        # inner class for handling frame adjustment loop
        class FrameAdjustment
          def initialize(dynamic_key:, inner_frame:)
            @dynamic_key = dynamic_key
            @inner_frame = inner_frame
          end

          def perform
            rows_missing_fee_info[[dynamic_key, "row", "sheet_name"]].to_a.map do |dynamic_row|
              inner_frame.concat(
                RowTransformer.new(
                  row: inner_frame[(inner_frame["row"] == dynamic_row["row"]) & (inner_frame["sheet_name"] == dynamic_row["sheet_name"])].to_a.first,
                  dynamic_key: dynamic_key,
                  types: inner_frame.types
                ).frame
              )
            end
          end

          private

          attr_reader :dynamic_key, :inner_frame

          def rows_missing_fee_info
            inner_frame[(!inner_frame[dynamic_key].missing) & (inner_frame["fee_code"].missing)]
          end
        end

        class RowTransformer
          # Dynamic Fees turn each dynamic column into a standard pricing row with fee_code and fee_name values

          def initialize(row:, dynamic_key:, types:)
            @row = row
            @dynamic_key = dynamic_key
            @types = types
          end

          def frame
            row["fee_code"] = dynamic_key.downcase
            row["fee_name"] = dynamic_key.upcase
            row["rate"] = row[dynamic_key]
            Rover::DataFrame.new([row], types: types)
          end

          private

          attr_reader :row, :dynamic_key, :types
        end
      end
    end
  end
end
