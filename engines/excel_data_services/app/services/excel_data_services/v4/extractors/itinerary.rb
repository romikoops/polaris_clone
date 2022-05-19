# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Itinerary < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Legacy::Itinerary.where(organization_id: organization_ids)
            .select("itineraries.id as itinerary_id, transshipment, origin_hub_id, destination_hub_id, organization_id")
        end

        def join_arguments
          {
            "transshipment" => "transshipment",
            "origin_hub_id" => "origin_hub_id",
            "destination_hub_id" => "destination_hub_id",
            "organization_id" => "organization_id"
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
      end
    end
  end
end
