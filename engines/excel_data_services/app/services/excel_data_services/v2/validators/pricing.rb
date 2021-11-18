# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Pricing < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Pricing.state(state: state)
        end

        def error_reason(row:)
          route_string = [row.values_at("origin", "origin_locode").join(", "), row.values_at("destination", "destination_locode").join(", ")].join(" - ")
          "The pricings '#{route_string} for #{row['cargo_class']}' cannot be found."
        end

        def required_key
          "pricing_id"
        end
      end
    end
  end
end
