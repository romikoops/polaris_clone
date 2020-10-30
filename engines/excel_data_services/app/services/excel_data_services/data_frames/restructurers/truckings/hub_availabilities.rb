# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class HubAvailabilities < ExcelDataServices::DataFrames::Restructurers::Truckings::TypeAvailabilities
          def combined_data
            frame.inner_join(valid_type_availabilities, on: library_args)
          end

          def insert_keys
            ["type_availability_id", "hub_id"]
          end

          def library_args
            {
              "truck_type" => "truck_type",
              "carriage" => "carriage",
              "load_type" => "load_type",
              "query_method" => "query_method",
              "country_id" => "country_id"
            }
          end

          def valid_type_availabilities
            type_availabilities
              .inner_join(query_methods, on: {"query_method" => "enum"})
              .tap do |sub_frame|
              sub_frame["query_method"] = sub_frame.delete("method")
            end
          end

          def type_availabilities
            @type_availabilities ||= Rover::DataFrame.new(
              ::Trucking::TypeAvailability.select(
                "query_method, truck_type, carriage, load_type, country_id, id AS type_availability_id"
              )
            )
          end

          def query_methods
            @query_methods ||= Rover::DataFrame.new(
              ::Trucking::TypeAvailability.query_methods.map { |method, enum|
                {"method" => method, "enum" => enum}
              }
            )
          end
        end
      end
    end
  end
end
