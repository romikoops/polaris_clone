# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Itinerary < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[origin_hub_id destination_hub_id mode_of_transport transshipment origin_name destination_name organization_id].freeze
        NAMESPACE_UUID = UUIDTools::UUID.parse(Legacy::Itinerary::UUID_V5_NAMESPACE)
        UUID_KEYS = %w[origin_hub_id destination_hub_id organization_id transshipment mode_of_transport].freeze

        def insertable_data
          frame[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            row["name"] = [row.delete("origin_name"), row.delete("destination_name")].join(" - ")
            row["upsert_id"] = upsert_id(row: row)
            row
          end
        end
      end
    end
  end
end
