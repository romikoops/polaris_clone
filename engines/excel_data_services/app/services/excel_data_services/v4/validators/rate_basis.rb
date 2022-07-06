# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class RateBasis < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::RateBasis.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          "The Rate Basis '#{row['rate_basis']}' is not recognized."
        end
      end
    end
  end
end
