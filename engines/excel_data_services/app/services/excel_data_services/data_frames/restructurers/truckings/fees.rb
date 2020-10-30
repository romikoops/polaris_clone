# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Restructurers::Base
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
              "fees" => build_fee_hash(truck_type: truck_type, carriage: carriage) || {},
              "truck_type" => truck_type,
              "carriage" => carriage
            }
          end

          def build_fee_hash(truck_type:, carriage:)
            frame[frame["truck_type"] == truck_type && frame["carriage"] == carriage].to_a
              .each_with_object({}) do |row, result|
                result.merge!(build_fee_from_row(row: row))
              end
          end

          def build_fee_from_row(row:)
            result = trimmed_row(row: row.except("truck_type", "direction", "carriage"))
            result["key"] = result.delete("fee_code")
            {result["key"] => result}
          end

          def fee_versions
            @fee_versions ||= frame[%w[truck_type carriage]].to_a.uniq
          end
        end
      end
    end
  end
end
