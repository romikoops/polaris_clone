# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class RateBasis < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::RateBasis.state(state: state)
        end

        def error_reason(row:)
          "The Rate Basis '#{row['rate_basis']}' is not recognized."
        end

        def required_key
          "rate_basis_id"
        end
      end
    end
  end
end
