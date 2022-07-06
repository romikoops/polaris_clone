# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class GrdbRateBasis < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::GrdbRateBasis.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          "The Rate Basis '#{row['rate_basis']}' is not recognized."
        end

        def required_key
          "grdb_rate_basis_found"
        end
      end
    end
  end
end
