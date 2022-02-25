# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class TruckingSheet < ExcelDataServices::V3::Validators::Base
        def extract_state
          @state
        end

        def append_errors_to_state
          invalid_zone_range_errors
          brackets_missing_errors
          bracket_gaps_errors
          duplicate_zone_errors
          expired_rates_errors
        end

        def brackets_missing_errors
          rate_frame[rate_frame["modifier"].missing].each_row do |frame_row|
            @state.errors << error(row: frame_row, message: "All rate Columns need a modifier to be defined in row 4.", attribute: "modifier")
          end
        end

        def bracket_gaps_errors
          rate_frame.group_by(["sheet_name"]).each do |sheet_rows|
            sheet_rows.group_by(["modifier"]).each do |modifier_rows|
              invalid_ranges = modifier_rows["range_min"].to_a.uniq.drop(1) - modifier_rows["range_max"].to_a.uniq.reverse.drop(1)
              next if invalid_ranges.empty?

              @state.errors << error(row: modifier_rows.to_a.first, message: "All ranges are exclusive. This means the last value of the range is ignored. Please ensure the next range starts with the same value the previous range ended with to ensure coverage.", attribute: "bracket")
            end
          end
        end

        def duplicate_zone_errors
          frame[!frame["row"].missing][["zone", identifier, "row"]].to_a.uniq
            .group_by { |row| row[identifier] }
            .reject { |_identifier_key, zones| zones.count == 1 }
            .each do |identifier_key, zone_rows|
              @state.errors << error(row: zone_rows.first, message: "Places cannot exist in multiple zones. #{identifier_key} is defined in mulitple zones (#{zone_rows.pluck('zone').join(', ')}). Please remove all but one.", attribute: identifier)
            end
        end

        def invalid_zone_range_errors
          frame["range"].to_a.uniq.compact.each do |range|
            next if range.match?(/[A-Z]{1,}/)

            values = range.split("-").map(&:strip).map(&:to_i)
            frame_row = frame[frame["range"] == range].first.to_a.first
            @state.errors << error(row: frame_row, message: "Invalid Range: Ranges are defined from lower bound to upper bound.", attribute: "range") if values.first > values.last
          end
        end

        def expired_rates_errors
          rate_frame[%w[expiration_date sheet_name]].to_a.uniq.reject { |date_and_sheet| Time.zone.today < date_and_sheet["expiration_date"] }.each do |frame_row|
            @state.errors << error(row: frame_row, message: "Already expired rates are not permitted.", attribute: "expiration_date")
          end
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def rate_frame
          @rate_frame ||= frame[frame["rate_type"] == "trucking_rate"]
        end

        def error(row:, message:, attribute:)
          ExcelDataServices::V3::Error.new(
            type: :warning,
            row_nr: row["#{attribute}_row"],
            col_nr: row["#{attribute}_column"],
            sheet_name: row["sheet_name"],
            reason: message,
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
