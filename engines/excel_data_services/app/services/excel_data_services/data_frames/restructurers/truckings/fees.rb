# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Restructurers::Base
          CONTEXT_KEYS = %w[fee mot fee_code truck_type direction currency rate_basis carriage].freeze

          def restructured_data
            if frame.blank?
              return [{
                "fees" => nil,
                "truck_type" => nil,
                "carriage" => nil
              }]
            end

            fee_versions.map do |row|
              build_fee_hash_row(truck_type: row["truck_type"], carriage: row["carriage"])
            end
          end

          def build_fee_hash_row(truck_type:, carriage:)
            {
              "fees" => build_fee_hash(inner_frame: frame[frame["truck_type"] == truck_type && frame["carriage"] == carriage]) || {},
              "truck_type" => truck_type,
              "carriage" => carriage
            }
          end

          def build_fee_hash(inner_frame:)
            inner_frame["fee_code"].to_a.each_with_object({}) do |fee_code, result|
              result.merge!(build_fee_from_row(fee_frame: inner_frame[inner_frame["fee_code"] == fee_code]))
            end
          end

          def build_fee_from_row(fee_frame:)
            row = fee_frame.to_a.first
            row["range"] = build_range_fee(fee_frame: fee_frame) if row["rate_basis"].include?("RANGE")

            result = trimmed_row(row: row.except("truck_type", "direction", "carriage"))
            result["key"] = result.delete("fee_code")
            { result["key"] => result }
          end

          def build_range_fee(fee_frame:)
            fee_frame.to_a.map do |range_row|
              trimmed_row(row: range_row).except(*CONTEXT_KEYS).transform_keys { |k| k.gsub("range_", "") }
            end
          end

          def fee_versions
            @fee_versions ||= frame[%w[truck_type carriage]].to_a.uniq
          end
        end
      end
    end
  end
end
