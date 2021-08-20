# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class RateBasis < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Pricings::RateBasis.select("id as rate_basis_id, external_code")
        end

        def join_arguments
          { "rate_basis" => "external_code" }
        end

        def frame_types
          { "rate_basis_id" => :object, "external_code" => :object }
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
