# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Pricing < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[
          cargo_class
          effective_date
          expiration_date
          internal
          transshipment
          vm_rate
          wm_rate
          group_id
          itinerary_id
          tenant_vehicle_id
          organization_id
        ].freeze
        NAMESPACE_UUID = UUIDTools::UUID.parse(Pricings::Pricing::UUID_V5_NAMESPACE)
        UUID_KEYS = %w[itinerary_id tenant_vehicle_id cargo_class group_id organization_id].freeze

        def insertable_data
          frame[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            row.slice(
              "cargo_class",
              "effective_date",
              "expiration_date",
              "vm_rate",
              "wm_rate",
              "group_id",
              "itinerary_id",
              "tenant_vehicle_id",
              "organization_id",
              "transshipment"
            )
              .merge(
                "fees" => RowFees.new(frame: frame, row: row).fees,
                "internal" => row["internal"].present?,
                "load_type" => row["cargo_class"] == "lcl" ? "cargo_item" : "container",
                "validity" => "[#{row['effective_date'].to_date}, #{row['expiration_date'].to_date})",
                "upsert_id" => upsert_id(row: row)
              )
          end
        end

        class RowFees
          attr_reader :row, :frame

          GROUPING_KEYS = %w[itinerary_id group_id cargo_class tenant_vehicle_id fee_code].freeze

          def initialize(frame:, row:)
            @frame = frame
            @row = row
          end

          def fees
            groupings.map { |grouping| fee_from_grouping_rows(grouped_rows: rows_from_grouping(grouping: grouping)) }
          end

          def rows_from_grouping(grouping:)
            mask = GROUPING_KEYS.map { |key| frame[key] == grouping[key] }.reduce(&:&)
            frame[mask]
          end

          def range_from_grouping_rows(grouped_rows:)
            filtered = grouped_rows[(!grouped_rows["range_min"].missing) & (!grouped_rows["range_max"].missing)].yield_self do |frame|
              frame["min"] = frame.delete("range_min")
              frame["max"] = frame.delete("range_max")
              frame
            end
            filtered[%w[min max rate]].to_a
          end

          def fee_from_grouping_rows(grouped_rows:)
            row = grouped_rows.to_a.first
            row.slice("organization_id", "base", "metadata", "min", "charge_category_id", "rate_basis_id", "rate")
              .merge(
                "currency_name" => row["currency_name"],
                "range" => range_from_grouping_rows(grouped_rows: grouped_rows)
              )
          end

          def groupings
            frame[GROUPING_KEYS].to_a.uniq
          end
        end
      end
    end
  end
end
