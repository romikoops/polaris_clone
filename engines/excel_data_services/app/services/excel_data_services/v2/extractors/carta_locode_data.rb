# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class CartaLocodeData < ExcelDataServices::V2::Extractors::Base
        # Due to the nature of the query we need to hit carta for each locode so abstracting the "extraction" to an Extractor class would be needlesly complicated

        def perform
          state.tap do |tapped_state|
            tapped_state.frame = frame.left_join(
              base_frame.concat(Rover::DataFrame.new(frame_data)),
              on: { "locode" => "locode" }
            )
          end
        end

        def frame_data
          frame["locode"].to_a.uniq.each_with_object([]) do |locode, rows|
            result = Carta::Client.suggest(query: locode)
            geocoded_result = Carta::Client.reverse_geocode(latitude: result.latitude, longitude: result.longitude)
            rows << geocoded_result.as_json
              .slice("latitude", "longitude", "address", "country")
              .merge("locode" => locode, "locode_found" => true)
          rescue Carta::Client::LocationNotFound
            { "locode" => locode, "locode_found" => nil }
          end
        end

        def base_frame
          Rover::DataFrame.new({
            "latitude" => [],
            "longitude" => [],
            "address" => [],
            "country" => [],
            "locode" => [],
            "locode_found" => []
          })
        end
      end
    end
  end
end
