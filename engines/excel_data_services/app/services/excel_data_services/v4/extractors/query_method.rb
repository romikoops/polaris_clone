# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class QueryMethod < ExcelDataServices::V4::Extractors::Base
        QUERY_METHOD_ENUM = Trucking::TypeAvailability.query_methods

        def frame_data
          [
            { "query_method" => QUERY_METHOD_ENUM["zipcode"], "query_type" => QueryType::QUERY_TYPE_ENUM["postal_code"] },
            { "query_method" => QUERY_METHOD_ENUM["location"], "query_type" => QueryType::QUERY_TYPE_ENUM["location"] },
            { "query_method" => QUERY_METHOD_ENUM["distance"], "query_type" => QueryType::QUERY_TYPE_ENUM["distance"] }
          ]
        end

        def join_arguments
          { "query_type" => "query_type" }
        end

        def frame_types
          { "query_method" => :object, "query_type" => :object }
        end
      end
    end
  end
end
