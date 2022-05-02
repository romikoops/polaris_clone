# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
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
          value
          rate
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
          group_row.slice("organization_id", "base", "min", "max", "charge_category_id", "rate_basis", "currency", "rate")
            .merge(
              "code" => group_row["fee_code"],
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
