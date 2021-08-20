# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Itinerary < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Legacy::Itinerary.where(organization_id: Organizations.current_id)
            .select("itineraries.id as itinerary_id, transshipment, origin_hub_id, destination_hub_id")
        end

        def join_arguments
          {
            "transshipment" => "transshipment",
            "origin_hub_id" => "origin_hub_id",
            "destination_hub_id" => "destination_hub_id"
          }
        end

        def frame_types
          {
            "transshipment" => :object,
            "itinerary_id" => :object,
            "destination_hub_id" => :object,
            "origin_hub_id" => :object
          }
        end

        def error_reason(row:)
          "The route '#{row['origin']} - #{row['destination']}' cannot be found."
        end

        def required_key
          "itinerary_id"
        end
      end
    end
  end
end
