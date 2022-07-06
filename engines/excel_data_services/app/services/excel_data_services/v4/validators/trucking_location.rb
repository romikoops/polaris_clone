# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class TruckingLocation < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::TruckingLocation.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          identifier = %w[postal_code city distance locode].find { |key| row[key].present? }
          secondary = %w[range province city].find { |key| row[key].present? }
          missing_location_description = row.values_at(identifier, secondary).compact.join(", ")
          "The location '#{missing_location_description}, (#{row['country_code']})' cannot be found."
        end
      end
    end
  end
end
