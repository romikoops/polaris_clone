# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Remark < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[origin_name destination_name pricing_id organization_id remarks].freeze

        def insertable_data
          frame[!frame["remarks"].missing][ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            {
              "header" => [row.delete("origin_name"), row.delete("destination_name")].join(" - "),
              "body" => row["remarks"],
              "pricings_pricing_id" => row["pricing_id"],
              "organization_id" => row["organization_id"]
            }
          end
        end
      end
    end
  end
end
