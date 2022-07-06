# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class LocationsLocation < ExcelDataServices::V4::Validators::Base
        def perform
          extract_state
          append_warnings_to_state
          filter_extracted_state
          state
        end

        private

        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::LocationsLocation.new(state: state, target_frame: target_frame).perform
        end

        def filter_extracted_state
          state.set_frame(value: recombined_frame, key: target_frame)
        end

        def recombined_frame
          non_location_based_frame.concat(location_based_frame[!location_based_frame[required_key].missing])
        end

        def append_warnings_to_state
          location_based_frame[location_based_frame[required_key].missing].to_a.each do |warning_row|
            append_warning(row: warning_row)
          end
        end

        def append_warning(row:)
          @state.warnings << ExcelDataServices::V4::Error.new(
            type: :warning,
            row_nr: row[row_key],
            col_nr: row[col_key],
            sheet_name: row["sheet_name"],
            reason: warning_reason(row: row),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def warning_reason(row:)
          "The location '#{row.values_at(*warning_value_keys).compact.join(', ')}' cannot be found."
        end

        def location_based_frame
          @location_based_frame ||= extracted.frame(target_frame).filter("query_type" => Extractors::QueryType::QUERY_TYPE_ENUM["location"])
        end

        def non_location_based_frame
          @non_location_based_frame ||= extracted.frame(target_frame).reject("query_type" => Extractors::QueryType::QUERY_TYPE_ENUM["location"])
        end

        def row_key
          "row"
        end

        def identifier
          @identifier ||= frame.first_row["identifier"]
        end

        def warning_value_keys
          @warning_value_keys ||= case identifier
                                  when "postal_city"
                                    %w[postal_code city country_code]
                                  when "city"
                                    %w[city province country_code]
                                  else
                                    [identifier, "range", "country_code"]
          end
        end
      end
    end
  end
end
