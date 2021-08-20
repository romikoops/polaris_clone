# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Pricing < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Rover::DataFrame.new(
            Pricings::Pricing.where(organization_id: Organizations.current_id)
            .for_dates(max_and_min_dates.first, max_and_min_dates.last)
            .map { |pricing| pricing_row(pricing: pricing) }
          )
        end

        def pricing_row(pricing:)
          pricing.slice("itinerary_id", "tenant_vehicle_id", "cargo_class", "group_id").merge(
            "pricing_id" => pricing.id,
            "effective_date" => pricing.effective_date.to_date,
            "expiration_date" => pricing.expiration_date.to_date
          )
        end

        def join_arguments
          {
            "itinerary_id" => "itinerary_id",
            "cargo_class" => "cargo_class",
            "group_id" => "group_id",
            "tenant_vehicle_id" => "tenant_vehicle_id",
            "effective_date" => "effective_date",
            "expiration_date" => "expiration_date"
          }
        end

        def frame_types
          { "pricing_id" => :object, "locode" => :object }
        end

        def error_reason(row:)
          route_string = [row.values_at("origin", "origin_locode").join(", "), row.values_at("destination", "destination_locode").join(", ")].join(" - ")
          "The pricings '#{route_string} for #{row['cargo_class']}' cannot be found."
        end

        def required_key
          "pricing_id"
        end

        def max_and_min_dates
          @max_and_min_dates ||= [frame["effective_date"].to_a.min, frame["expiration_date"].to_a.min]
        end
      end
    end
  end
end
