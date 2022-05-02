# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class QueryType < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::QueryType.state(state: state)
        end

        def error_reason(row:)
          "The value '#{row['identifier'].upcase}' is not valid."
        end

        def required_key
          "query_type"
        end
      end
    end
  end
end
