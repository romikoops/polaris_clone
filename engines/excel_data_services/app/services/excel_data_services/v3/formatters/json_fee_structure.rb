# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class JsonFeeStructure
        attr_reader :frame

        def initialize(frame:)
          @frame = frame
        end

        def perform
          fee_codes.each_with_object({}) do |fee_code, fee_result|
            fee_result[fee_code.upcase] = FeesHash.new(frame: frame.filter("fee_code" => fee_code)).perform
          end
        end

        def fee_codes
          @fee_codes ||= frame["fee_code"].to_a.uniq
        end

        class FeesHash
          attr_reader :frame

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
            rate
            value
          ].freeze

          def initialize(frame:)
            @frame = frame
          end

          def perform
            row.slice("base", "min", "max", "rate_basis", "currency")
              .merge(
                "range" => range_from_grouping_rows,
                "name" => row["fee_name"],
                "key" => row["fee_code"].upcase,
                active_fee_key => row[active_fee_key].to_d
              )
          end

          def row
            @row ||= frame.to_a.first
          end

          def range_from_grouping_rows
            filtered = frame[(!frame["range_min"].missing) & (!frame["range_max"].missing)].yield_self do |frame|
              frame["min"] = frame.delete("range_min").to(:float)
              frame["max"] = frame.delete("range_max").to(:float)
              frame[active_fee_key] = frame[active_fee_key].to(:float)
              frame
            end
            filtered[["min", "max", active_fee_key]].to_a
          end

          def active_fee_key
            @active_fee_key ||= FEE_KEYS.find { |key| row[key].present? }
          end
        end
      end
    end
  end
end
