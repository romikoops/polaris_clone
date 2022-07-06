# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Country < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Country.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          "The country '#{row.values_at('country', 'country_code').compact.join(' ')}' cannot be found."
        end

        def required_key
          "country_id"
        end
      end
    end
  end
end
