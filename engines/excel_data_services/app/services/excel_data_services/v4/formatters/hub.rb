# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Hub < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[name locode organization_id latitude longitude address_id mandatory_charge_id hub_status hub_type terminal terminal_code nexus_id].freeze

        def insertable_data
          frame[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            HubFromRow.new(row: row).hub
          end
        end

        class HubFromRow
          def initialize(row:)
            @row = row
          end

          def hub
            row.slice(
              "name",
              "organization_id",
              "latitude",
              "longitude",
              "mandatory_charge_id",
              "hub_status",
              "hub_type",
              "terminal",
              "terminal_code",
              "nexus_id",
              "address_id"
            ).merge(
              "hub_code" => row.delete("locode"),
              "point" => point
            )
          end

          private

          attr_reader :row

          def point
            RGeo::Geos.factory(srid: 4326).point(row["longitude"], row["latitude"])
          end
        end
      end
    end
  end
end
