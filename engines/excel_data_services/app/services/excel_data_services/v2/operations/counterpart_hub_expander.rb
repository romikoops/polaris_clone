# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Operations
      class CounterpartHubExpander < ExcelDataServices::V2::Operations::Base
        IDENTIFYING_KEYS = %w[group_id
          group_name
          effective_date
          expiration_date
          locode
          hub
          terminal
          country
          counterpart_locode
          counterpart_hub
          counterpart_terminal
          counterpart_country
          mode_of_transport
          carrier
          direction
          service_level
          load_type].freeze
        COUNTERPART_KEYS = %w[
          counterpart_locode
          counterpart_hub
          counterpart_terminal
          counterpart_country
        ].freeze

        def operation_result
          @operation_result ||= general_fees.concat(expanded_result)
        end

        def expanded_result
          @expanded_result ||= counterpart_assigned_fees[present_identifying_keys].to_a.uniq.each_with_object(empty_frame) do |row, result_frame|
            result_frame.concat(
              ExpandedFrame.new(
                row: row,
                counterpart_frame: counterpart_assigned_fees,
                expandable_frame: general_fees
              ).expanded_frame
            )
          end
        end

        def general_fees
          @general_fees ||= frame[(frame["counterpart_hub"].missing) & (frame["counterpart_locode"].missing)]
        end

        def counterpart_assigned_fees
          @counterpart_assigned_fees ||= frame[(!frame["counterpart_hub"].missing) | (!frame["counterpart_locode"].missing)]
        end

        def present_identifying_keys
          frame.keys & IDENTIFYING_KEYS
        end

        def empty_frame
          Rover::DataFrame.new({ "sheet_name" => [], "row" => [] })
        end

        class ExpandedFrame
          def initialize(row:, counterpart_frame:, expandable_frame:)
            @row = row
            @counterpart_frame = counterpart_frame
            @expandable_frame = expandable_frame
          end

          def expanded_frame
            general_rates_to_concat
              .concat(counterpart_rates_to_concat)
              .concat(merged_rates_to_concat)
              .left_join(counterpart_info_for_expansion, on: "sheet_name")
          end

          private

          attr_reader :row, :counterpart_frame, :expandable_frame

          def merged_rates_to_concat
            @merged_rates_to_concat ||= general_rates_to_merge.left_join(counterpart_rates_to_merge, on: { "fee_code" => "fee_code" })
          end

          def general_rates_to_concat
            @general_rates_to_concat ||= expandable_rows[!expandable_rows["fee_code"].in?(counterpart_codes)]
          end

          def counterpart_rates_to_concat
            @counterpart_rates_to_concat ||= counterpart_rows[!counterpart_rows["fee_code"].in?(expandable_codes)]
          end

          def general_rates_to_merge
            @general_rates_to_merge ||= expandable_rows[expandable_rows["fee_code"].in?(counterpart_codes)]
          end

          def counterpart_rates_to_merge
            @counterpart_rates_to_merge ||= counterpart_rows[counterpart_rows["fee_code"].in?(expandable_codes)]
          end

          def counterpart_info_for_expansion
            @counterpart_info_for_expansion ||= Rover::DataFrame.new(counterpart_rows[(row.keys & COUNTERPART_KEYS) + ["sheet_name"]].to_a.uniq)
          end

          def counterpart_rows
            @counterpart_rows ||= row_frame(input_frame: counterpart_frame, row: row)
          end

          def expandable_rows
            @expandable_rows ||= row_frame(input_frame: expandable_frame, row: row.except(*CounterpartHubExpander::COUNTERPART_KEYS))
              .left_join(counterpart_info_for_expansion, on: "sheet_name")
          end

          def expandable_codes
            @expandable_codes ||= expandable_rows["fee_code"].to_a
          end

          def counterpart_codes
            @counterpart_codes ||= counterpart_rows["fee_code"].to_a
          end

          def row_frame(input_frame:, row:)
            ExcelDataServices::V2::Helpers::FrameFilter.new(input_frame: input_frame, arguments: row).frame
          end
        end
      end
    end
  end
end
