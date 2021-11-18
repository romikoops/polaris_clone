# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Country < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Country.state(state: state)
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
