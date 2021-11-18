# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class RouteHubs < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::RouteHubs.state(state: state)
        end

        def required_keys
          %w[origin_hub_id destination_hub_id]
        end

        def missing_hub_details(row:, key:)
          prefix = key.include?("origin") ? "origin" : "destination"

          row.values_at(prefix, "#{prefix}_terminal", "#{prefix}_locode", "country_#{prefix}").compact.join(", ")
        end

        def error_reason(row:, required_key:)
          "The hub '#{missing_hub_details(row: row, key: required_key)}' cannot be found. Please check that the information is entered correctly"
        end

        def append_errors_to_state
          required_keys.each { |required_key| append_required_key_errors(required_key: required_key) }
        end

        def append_required_key_errors(required_key:)
          frame[frame[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row, required_key: required_key)
          end
        end

        def append_error(row:, required_key:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :warning,
            row_nr: row["row"],
            sheet_name: row["sheet_name"],
            reason: error_reason(row: row, required_key: required_key),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
