# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Pricing < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Pricing.state(state: state)
        end

        def error_reason(row:)
          route_string = [row.values_at("origin", "origin_locode").join(", "), row.values_at("destination", "destination_locode").join(", ")].join(" - ")
          "The pricings '#{route_string} for #{row['cargo_class']}' cannot be found."
        end

        def required_key
          "pricing_id"
        end

        def row_key
          "origin_row"
        end

        def col_key
          "origin_column"
        end
      end
    end
  end
end
