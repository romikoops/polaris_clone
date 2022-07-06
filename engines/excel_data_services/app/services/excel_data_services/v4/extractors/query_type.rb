# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class QueryType < ExcelDataServices::V4::Extractors::Base
        QUERY_TYPE_ENUM = Trucking::Location.queries

        def extracted
          @extracted ||= postal_code_rows.concat(location_rows).concat(distance_rows).concat(postal_city_rows).concat(error_rows)
        end

        def postal_code_rows
          @postal_code_rows ||= postal_based_rows
            .left_join(location_postal_countries, on: { "identifier" => "identifier", "country_code" => "country_code" })
            .left_join(string_postal_countries, on: { "identifier" => "identifier", "country_code" => "country_code" })
        end

        def location_rows
          @location_rows ||= zone_frame[zone_frame["identifier"].in?(%w[city locode])].tap do |location_frame|
            location_frame["query_type"] = QUERY_TYPE_ENUM["location"]
          end
        end

        def distance_rows
          @distance_rows ||= zone_frame.filter("identifier" => "distance").tap do |distance_frame|
            distance_frame["query_type"] = QUERY_TYPE_ENUM["distance"]
          end
        end

        def postal_city_rows
          @postal_city_rows ||= zone_frame.filter("identifier" => "postal_city").tap do |postal_city_frame|
            postal_city_frame["query_type"] = QUERY_TYPE_ENUM["location"]
          end
        end

        def postal_based_rows
          @postal_based_rows ||= zone_frame.filter("identifier" => "postal_code")
        end

        def error_rows
          @error_rows ||= zone_frame[!zone_frame["identifier"].in?(%w[city locode postal_code distance postal_city])]
        end

        def location_postal_countries
          @location_postal_countries ||= base_frame.concat(
            Rover::DataFrame.new(
              location_country_codes.map do |country_code|
                {
                  "country_code" => country_code,
                  "query_type" => QUERY_TYPE_ENUM["location"],
                  "identifier" => "postal_code"
                }
              end,
              types: { "query_type" => :object }
            )
          )
        end

        def string_postal_countries
          @string_postal_countries ||= base_frame.concat(
            Rover::DataFrame.new(
              (country_codes - location_country_codes).map do |country_code|
                {
                  "country_code" => country_code.upcase,
                  "query_type" => QUERY_TYPE_ENUM["postal_code"],
                  "identifier" => "postal_code"
                }
              end,
              types: { "query_type" => :object }
            )
          )
        end

        def location_country_codes
          @location_country_codes ||= Locations::Location.select(:country_code).distinct.pluck(:country_code).map(&:upcase)
        end

        def country_codes
          @country_codes ||= zone_frame["country_code"].to_a.uniq
        end

        def zone_frame
          @zone_frame ||= state.frame("zones")
        end

        def base_frame
          @base_frame ||= Rover::DataFrame.new({
            "country_code" => [],
            "query_type" => [],
            "identifier" => []
          }, types: { "query_type" => :object })
        end
      end
    end
  end
end
