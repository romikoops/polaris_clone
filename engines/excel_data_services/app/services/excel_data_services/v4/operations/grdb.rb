# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      class Grdb < ExcelDataServices::V4::Operations::Base
        def operation_result
          @operation_result ||= frame_adjusted_for_transshipments_and_countries
        end

        def frame_not_on_request
          @frame_not_on_request ||= frame_adjusted_for_on_request.reject("rate" => "on request")
        end

        def frame_adjusted_for_on_request
          @frame_adjusted_for_on_request ||= frame_present.left_join(rows_on_request, on: { "row" => "row" })
        end

        def rows_on_request
          @rows_on_request ||= frame_present.filter("fee_code" => "ocean_freight", "rate" => "on request")[%w[row rate]]
        end

        def frame_present
          @frame_present ||= frame[!frame["rate"].missing]
        end

        def frame_adjusted_for_transshipments_and_countries
          @frame_adjusted_for_transshipments_and_countries ||= Rover::DataFrame.new(
            frame_with_renamed_columns.to_a.map do |row|
              combined_transshipments(row: row)
            end
          )
        end

        def frame_with_renamed_columns
          @frame_with_renamed_columns ||= frame_not_on_request.tap do |tapped_frame|
            tapped_frame["min"] = tapped_frame["minimum"]
            tapped_frame["max"] = tapped_frame["maximum"]
            tapped_frame["remarks"] = tapped_frame["notes"]
          end
        end

        def combined_transshipments(row:)
          combined_transshipments = row.values_at("transhipment_1", "transhipment_2", "transhipment_3").select(&:present?)
          row.merge(
            "transshipment" => combined_transshipments.present? ? combined_transshipments.join("_") : nil
          )
        end
      end
    end
  end
end
