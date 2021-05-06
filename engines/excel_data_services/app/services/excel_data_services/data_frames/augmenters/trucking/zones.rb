# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class Zones < ExcelDataServices::DataFrames::Augmenters::Base
          BATCH_SIZE = 2000

          def perform
            super
            import_locations
            remove_sheet_name
            state.frame = valid_frame
            state
          end

          def import_locations
            ::Trucking::Location.import(insertable_locations, {
              on_duplicate_key_ignore: true
            })
          end

          def insertable_locations
            existing_ids = []
            upsert_ids_with_locations.keys.each_slice(BATCH_SIZE) do |id_batch|
              existing_batch = ::Trucking::Location.where(upsert_id: id_batch).pluck(:upsert_id)
              existing_ids.append(*existing_batch)
            end

            upsert_ids_with_locations.except(*existing_ids).values
          end

          def upsert_ids_with_locations
            @upsert_ids_with_locations ||= all_locations.index_by(&:generate_upsert_id)
          end

          def all_locations
            combined = postal_code_locations
              .concat(distance_locations)
              .concat(locode_locations)
              .inner_join(countries, on: { "country_code" => "code" })
            combined[%w[data query country_id]].to_a.map do |row|
              ::Trucking::Location.new(data: row["data"], query: row["query"], country_id: row["country_id"])
            end
          end

          def postal_code_locations
            Rover::DataFrame.new(
              postal_code_location_data,
              types: { "query" => :object, "data" => :object, "country_id" => :object }
            )
          end

          def postal_code_location_data
            non_validated_country_codes.reduce(Rover::DataFrame.new) do |memo, country_code|
              locations = postal_code_rows[postal_code_rows["country_code"] == country_code][%w[primary country_code]]
              locations["data"] = locations.delete("primary")
              locations["query"] = "postal_code"

              memo.concat(locations[%w[data query country_code]])
            end
          end

          def valid_frame
            @valid_frame ||= valid_postal_code_frame.concat(locode_rows).concat(distance_rows).concat(city_rows)
          end

          def valid_postal_code_frame
            country_codes.reduce(Rover::DataFrame.new) do |memo, country_code|
              country_rows = postal_code_rows[postal_code_rows["country_code"] == country_code]

              if validated_country_codes.include?(country_code)
                country_rows = country_rows.inner_join(
                  validated_country_postal_codes,
                  on: { "primary" => "postal_code", "country_code" => "country_code" }
                )
              end
              memo.concat(country_rows)
            end
          end

          def distance_locations
            locations = distance_rows[%w[primary country_code]]
            locations["data"] = locations.delete("primary")
            locations["query"] = "distance"

            locations[%w[data query country_code]]
          end

          def locode_locations
            locations = locode_collection[%w[primary country_code location_id]]
            locations["data"] = locations.delete("primary")
            locations["query"] = "location"

            locations[%w[data query country_code]]
          end

          def locode_collection
            @locode_collection ||= Rover::DataFrame.new(
              locode_data_for_collection,
              types: { "primary" => :object, "country_code" => :object, "location_id" => :object }
            )
          end

          def locode_data_for_collection
            locode_rows[%w[primary country_code]].to_a.each_with_object(initial_state) do |row, result|
              result["primary"] << row["primary"]
              result["country_code"] << row["country_code"]
              result["location_id"] << ::Locations::Searchers::Locode.id(data: { locode: row["primary"] })
              result
            end
          end

          def initial_state
            {
              "primary" => [],
              "country_code" => [],
              "location_id" => []
            }
          end

          def countries
            @countries ||= Rover::DataFrame.new(
              Legacy::Country.where(code: country_codes).select("id as country_id, code")
            )
          end

          def country_codes
            @country_codes ||= frame["country_code"].uniq.to_a
          end

          def non_validated_country_codes
            @non_validated_country_codes ||= country_codes - validated_country_codes
          end

          def validated_country_codes
            @validated_country_codes ||= ::Trucking::PostalCodes.country_codes.map(&:upcase)
          end

          def validated_country_postal_codes
            @validated_country_postal_codes ||= Rover::DataFrame.new(::Trucking::PostalCodes.all)
          end

          def locodes
            @locodes ||= @locode_rows[!@locode_rows["primary"].missing]["primary"].uniq.to_a + [nil]
          end

          def postal_code_rows
            @postal_code_rows ||= frame[frame["identifier"] == "postal_code"].concat(
              frame[frame["identifier"] == "zipcode"]
            )
          end

          def locode_rows
            @locode_rows ||= frame[frame["identifier"] == "locode"]
          end

          def city_rows
            @city_rows ||= frame[frame["identifier"] == "city"]
          end

          def distance_rows
            @distance_rows ||= frame[frame["identifier"] == "distance"]
          end
        end
      end
    end
  end
end
