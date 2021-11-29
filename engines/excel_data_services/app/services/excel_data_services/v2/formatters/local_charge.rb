# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class LocalCharge < ExcelDataServices::V2::Formatters::Base
        GROUPING_KEYS = %w[
          cargo_class
          effective_date
          expiration_date
          direction
          mode_of_transport
          hub_id
          counterpart_hub_id
          internal
          group_id
          tenant_vehicle_id
          organization_id
          dangerous
        ].freeze
        NAMESPACE_UUID = UUIDTools::UUID.parse(Legacy::LocalCharge::UUID_V5_NAMESPACE)
        UUID_KEYS = %w[hub_id counterpart_hub_id tenant_vehicle_id load_type mode_of_transport group_id direction organization_id].freeze

        def insertable_data
          frame[GROUPING_KEYS].to_a.uniq.map do |row|
            loop_frame = filtered_frame(input_frame: frame, arguments: row)
            first_row = loop_frame.to_a.first
            first_row.slice(
              "effective_date",
              "expiration_date",
              "hub_id",
              "counterpart_hub_id",
              "group_id",
              "tenant_vehicle_id",
              "organization_id",
              "dangerous",
              "internal",
              "cbm_ratio"
            )
              .merge(
                "metadata" => metadata(row_grouping: loop_frame),
                "fees" => RowFeesHash.new(frame: loop_frame, state: state).fees,
                "load_type" => row["cargo_class"],
                "validity" => "[#{row['effective_date'].to_date}, #{row['expiration_date'].to_date})",
                "uuid" => upsert_id(row: row)
              )
          end
        end

        def metadata(row_grouping:)
          first_of_group = row_grouping.to_a.first
          first_of_group.slice("sheet_name").tap do |combined_metadata|
            combined_metadata["row_number"] = row_grouping["row"].to_a.join(",")
            combined_metadata["file_name"] = state.file_name
            combined_metadata["document_id"] = state.file.id
          end
        end

        class RowFeesHash
          attr_reader :frame, :state

          FEE_KEYS = %w[
            ton
            cbm
            kg
            item
            shipment
            bill
            container
            wm
            percentage
          ].freeze

          def initialize(frame:, state:)
            @frame = frame
            @state = state
          end

          def fees
            fee_codes.each_with_object({}) do |fee_code, fee_result|
              fee_result[fee_code.upcase] = fee_from_grouping_rows(grouped_rows: rows_from_grouping(fee_code: fee_code))
            end
          end

          def rows_from_grouping(fee_code:)
            frame[frame["fee_code"] == fee_code]
          end

          def range_from_grouping_rows(grouped_rows:, active_fee_key:)
            filtered = grouped_rows[(!grouped_rows["range_min"].missing) & (!grouped_rows["range_max"].missing)].yield_self do |frame|
              frame["min"] = frame.delete("range_min")
              frame["max"] = frame.delete("range_max")
              frame
            end
            filtered[["min", "max", active_fee_key]].to_a
          end

          def fee_from_grouping_rows(grouped_rows:)
            group_row = grouped_rows.to_a.first
            active_fee_key = FEE_KEYS.find { |key| group_row[key].present? }
            group_row.slice("organization_id", "base", "min", "max", "charge_category_id", "rate_basis_id", "currency", "rate")
              .merge(
                "range" => range_from_grouping_rows(grouped_rows: grouped_rows, active_fee_key: active_fee_key),
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
      end
    end
  end
end
