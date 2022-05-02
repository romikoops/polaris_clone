# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class QueryMethod < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::QueryMethod.state(state: state)
        end

        def error_reason(row:)
          "The value '#{row['identifier'].upcase}' is not valid."
        end

        def required_key
          "query_method"
        end
      end
    end
  end
end
