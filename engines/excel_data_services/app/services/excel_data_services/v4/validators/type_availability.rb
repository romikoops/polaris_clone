# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class TypeAvailability < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::TypeAvailability.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          identifier = %w[postal_code city distance locode].find { |key| row[key].present? }
          "The type availability '#{row[identifier]} (#{row['country_code']})' cannot be found."
        end

        def key_base
          "type_availability"
        end
      end
    end
  end
end
