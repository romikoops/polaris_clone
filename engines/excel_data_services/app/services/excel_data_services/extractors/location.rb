# frozen_string_literal: true

module ExcelDataServices
  module Extractors
    class Location < ExcelDataServices::Extractors::Base
      BATCH_SIZE = 5000

      def frame_data
        Rover::DataFrame.new
          .concat(batched_locations)
          .concat(city_locations)
      end

      def join_arguments
        return {"zone" => "zone"} if identifier == "city"

        {"primary" => "data"}
      end

      def identifier
        @identifier ||= frame["identifier"].to_a.first
      end

      def batched_locations
        batched_frame = Rover::DataFrame.new
        primaries.each_slice(BATCH_SIZE) do |primary_batch|
          batched_frame.concat(Rover::DataFrame.new(filtered_locations.where(data: primary_batch).select(
            "trucking_locations.id as location_id, trucking_locations.data"
          )))
        end
        batched_frame
      end

      def city_locations
        @city_locations ||= Rover::DataFrame.new(
          frame[frame["identifier"] == "city"].to_a.map { |row|
            trucking_location_data_from_row(row: row)
          }
        )
      end

      def filtered_locations
        @filtered_locations ||= Trucking::Location.joins(:country).where(countries: {code: country_codes})
      end

      def country_codes
        @country_codes ||= frame["country_code"].uniq.to_a
      end

      def primaries
        @primaries ||= frame[!frame["primary"].missing]["primary"].uniq.to_a
      end

      def trucking_location_data_from_row(row:)
        location_id = geometry_from_row(row: row)
        return row.merge("location_id" => nil) if location_id.blank?

        trucking_location = Trucking::Location.find_or_initialize_by(
          location_id: location_id,
          country: Legacy::Country.find_by(code: row["country_code"])
        )
          .tap do |tapped_trucking_location|
          return tapped_trucking_location if tapped_trucking_location.id.present?

          tapped_trucking_location.city_name = row.values_at("primary", "secondary").join(", ")
          tapped_trucking_location.save
        end

        trucking_location.as_json(only: %i[data location_id country_id])
          .merge(zone: row["zone"], location_id: trucking_location.id).stringify_keys
      end

      def geometry_from_row(row:)
        prepared_data = GeoDataPreparer.data(identifier: identifier, raw_data: row)
        ::Locations::LocationSearcher.get(identifier: identifier).id(data: prepared_data)
      end
    end
  end
end
