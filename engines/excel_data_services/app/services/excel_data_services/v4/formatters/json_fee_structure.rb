# frozen_string_literal: true

module ExcelDataServices
  module V4
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
            active_fee_keys.inject(fee_base) do |fee, active_fee_key|
              next fee unless range_frame.empty?

              fee.merge(active_fee_key => row.values_at(active_fee_key, "rate", "value").find(&:present?).to_d)
            end
          end

          def fee_base
            @fee_base ||= row.slice("base", "min", "max", "rate_basis", "currency", "cbm_ratio", "vm_ratio")
              .merge(
                "range" => range_from_grouping_rows,
                "name" => row["fee_name"],
                "key" => row["fee_code"].upcase
              )
          end

          def row
            @row ||= frame.to_a.first
          end

          def range_from_grouping_rows
            @range_from_grouping_rows ||= present_active_fee_keys.inject([]) do |result, active_fee_key|
              result.concat(range_frame[!range_frame[active_fee_key].missing][["min", "max", active_fee_key]].to_a)
            end
          end

          def range_frame
            @range_frame ||= frame[(!frame["range_min"].missing) & (!frame["range_max"].missing)].yield_self do |frame|
              frame["min"] = frame.delete("range_min").to(:float)
              frame["max"] = frame.delete("range_max").to(:float)
              frame
            end
          end

          def rate_basis
            row["rate_basis"]
          end

          def present_active_fee_keys
            present_and_active = active_fee_keys & frame.keys
            present_and_active || ["rate"]
          end

          def active_fee_keys
            @active_fee_keys ||= if rate_basis == "PER_UNIT_TON_CBM_RANGE"
              %w[cbm ton]
            else
              rate_basis
                .split("_")
                .reject { |part| part.in?(%w[PER X RANGE FLAT]) }
                .map(&:downcase)
            end
          end
        end
      end
    end
  end
end
