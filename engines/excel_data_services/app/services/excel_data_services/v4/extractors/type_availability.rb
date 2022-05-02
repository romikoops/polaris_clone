# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class TypeAvailability < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Trucking::TypeAvailability.joins(:country).where(countries: { code: country_codes }, query_method: query_methods)
            .select(
              "trucking_type_availabilities.id as type_availability_id,
              trucking_type_availabilities.truck_type,
              trucking_type_availabilities.carriage,
              trucking_type_availabilities.load_type,
              countries.code as country_code"
            )
        end

        def join_arguments
          {
            "truck_type" => "truck_type",
            "carriage" => "carriage",
            "load_type" => "load_type",
            "country_code" => "country_code"
          }
        end

        def frame_types
          {
            "truck_type" => :object,
            "carriage" => :object,
            "load_type" => :object,
            "country_code" => :object
          }
        end

        def query_methods
          @query_methods ||= frame["query_method"].to_a.uniq
        end

        def country_codes
          frame["country_code"].uniq.to_a
        end
      end
    end
  end
end
