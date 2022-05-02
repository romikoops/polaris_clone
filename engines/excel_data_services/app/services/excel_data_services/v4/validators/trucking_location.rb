# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class TruckingLocation < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::TruckingLocation.state(state: state)
        end

        def error_reason(row:)
          identifier = %w[postal_code city distance locode].find { |key| row[key].present? }
          "The location '#{row[identifier]} (#{row['country_code']})' cannot be found."
        end
      end
    end
  end
end
