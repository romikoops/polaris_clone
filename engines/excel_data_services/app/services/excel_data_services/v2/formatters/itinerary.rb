# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Itinerary < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[origin_hub_id destination_hub_id mode_of_transport transshipment origin_name destination_name organization_id].freeze
        NAMESPACE_UUID = UUIDTools::UUID.parse(Legacy::Itinerary::UUID_V5_NAMESPACE)
        UUID_KEYS = %w[origin_hub_id destination_hub_id organization_id transshipment mode_of_transport].freeze

        def insertable_data
          rows_for_insertion[ATTRIBUTE_KEYS].to_a.uniq.map { |row| ItineraryRow.new(row: row, upsert_id: upsert_id(row: row)).data }
        end

        def target_attribute
          "itinerary_id"
        end

        class ItineraryRow
          def initialize(row:, upsert_id:)
            @row = row
            @upsert_id = upsert_id
          end

          def data
            row["name"] = [row.delete("origin_name"), row.delete("destination_name")].join(" - ")
            row["upsert_id"] = upsert_id
            row["stops"] = stops_from_row
            row
          end

          private

          attr_reader :row, :upsert_id

          def stops_from_row
            %w[origin destination].map.with_index do |target, index|
              { hub_id: row["#{target}_hub_id"], index: index }
            end
          end
        end
      end
    end
  end
end
