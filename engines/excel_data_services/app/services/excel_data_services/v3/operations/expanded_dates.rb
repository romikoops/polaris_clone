# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      class ExpandedDates < ExcelDataServices::V3::Operations::Base
        IDENTIFYING_KEYS = %w[group_id
          group_name
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
          load_type
          cargo_class
          postal_code
          city
          distance].freeze

        def operation_result
          @operation_result ||= frame[present_identifying_keys].to_a.uniq.each_with_object(empty_frame) do |row, result_frame|
            result_frame.concat(
              ExpandedFrame.new(
                row: row,
                frame: frame.filter(row)
              ).expanded_frame
            )
          end
        end

        def present_identifying_keys
          frame.keys & IDENTIFYING_KEYS
        end

        class ExpandedFrame
          def initialize(row:, frame:)
            @row = row
            @frame = frame
          end

          def expanded_frame
            return frame if validities.length == 1

            frame.inner_join(expanded_dates_for_row, on: {
              "effective_date" => "original_effective_date",
              "expiration_date" => "original_expiration_date"
            })
          end

          private

          attr_reader :row, :frame

          def validities
            @validities ||= frame[%w[effective_date expiration_date]].to_a.uniq
          end

          def expanded_dates_for_row
            @expanded_dates_for_row ||= validities.inject(Rover::DataFrame.new) do |result, validity|
              result.concat(ExcelDataServices::V3::Operations::Dynamic::ExpandedDatesFrame.new(row: validity, row_frame: frame).frame)
            end
          end
        end
      end
    end
  end
end
