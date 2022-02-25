# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class Pricing < ExcelDataServices::V3::Formatters::Base
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
        GROUPING_KEYS = %w[itinerary_id group_id cargo_class tenant_vehicle_id effective_date expiration_date].freeze
        NAMESPACE_UUID = ::UUIDTools::UUID.parse(Pricings::Pricing::UUID_V5_NAMESPACE)
        UUID_KEYS = %w[itinerary_id tenant_vehicle_id cargo_class group_id organization_id].freeze

        def insertable_data
          rows_for_insertion[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            loop_frame = frame.filter(row)
            row.slice(
              "cargo_class",
              "effective_date",
              "expiration_date",
              "wm_rate",
              "group_id",
              "itinerary_id",
              "tenant_vehicle_id",
              "organization_id",
              "transshipment"
            )
              .merge(
                "vm_rate" => row["vm_rate"].present? ? row["vm_rate"].to_f / 1000.0 : 1.0,
                "fees" => RowFees.new(frame: loop_frame, state: state).fees,
                "notes" => RowNotes.new(frame: loop_frame).notes,
                "internal" => row["internal"].present?,
                "load_type" => row["cargo_class"] == "lcl" ? "cargo_item" : "container",
                "validity" => "[#{row['effective_date'].to_date}, #{row['expiration_date'].to_date})",
                "upsert_id" => upsert_id(row: row)
              )
          end
        end

        def target_attribute
          "pricing_id"
        end

        class RowFees
          attr_reader :frame, :state

          def initialize(frame:, state:)
            @frame = frame
            @state = state
          end

          def fees
            fee_codes.map { |fee_code| fee_from_grouping_rows(grouped_rows: rows_from_grouping(fee_code: fee_code)) }
          end

          def rows_from_grouping(fee_code:)
            frame[frame["fee_code"] == fee_code]
          end

          def range_from_grouping_rows(grouped_rows:)
            filtered = grouped_rows[(!grouped_rows["range_min"].missing) & (!grouped_rows["range_max"].missing)].yield_self do |frame|
              frame["min"] = frame.delete("range_min").to(:float)
              frame["max"] = frame.delete("range_max").to(:float)
              frame["rate"] = frame["rate"].to(:float)
              frame
            end
            filtered[%w[min max rate]].to_a.uniq
          end

          def fee_from_grouping_rows(grouped_rows:)
            group_row = grouped_rows.to_a.first
            group_row.slice("organization_id", "base", "min", "charge_category_id", "rate_basis_id", "rate")
              .merge(
                "currency_name" => group_row["currency"],
                "range" => range_from_grouping_rows(grouped_rows: grouped_rows),
                "metadata" => metadata(row_grouping: grouped_rows)
              )
          end

          def fee_codes
            frame["fee_code"].to_a.uniq
          end

          def metadata(row_grouping:)
            first_of_group = row_grouping.to_a.first
            first_of_group.slice("sheet_name").tap do |combined_metadata|
              combined_metadata["row_number"] = row_grouping["row"].to_a.uniq.join(",")
              combined_metadata["file_name"] = state.file_name
              combined_metadata["document_id"] = state.file.id
            end
          end
        end

        class RowNotes
          attr_reader :frame

          def initialize(frame:)
            @frame = frame
          end

          def notes
            note_frame.to_a
              .uniq { |note_row| note_row["remarks"] }
              .map do |note_row|
              {
                "header" => [note_row["origin_name"], note_row["destination_name"]].join(" - "),
                "body" => note_row["remarks"],
                "organization_id" => note_row["organization_id"]
              }
            end
          end

          def note_frame
            @note_frame ||= frame[!frame["remarks"].missing]
          end
        end
      end
    end
  end
end
