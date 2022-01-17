# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Country < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Country.state(state: state)
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
