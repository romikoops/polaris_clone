# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Restructurers::Base
          def restructured_data
            fee_versions.map(&:frame_row).uniq
          end

          def fee_versions
            @fee_versions ||= frame[%w[truck_type carriage zone tenant_vehicle_id cargo_class]].to_a.uniq.map do |version|
              FeeVersion.new(version: Version.new(**version.symbolize_keys), frame: frame)
            end
          end

          # A Version is a struct that holds the keys defining a particular 'version' of trucking pricing ( zone, cargo_class, tenant_vehicle_id, carriage and truck_type)
          Version = Struct.new(:truck_type, :carriage, :tenant_vehicle_id, :zone, :cargo_class, keyword_init: true)

          class FeeVersion
            # FeeVersion will filter out all rows from the data frame that match the given arguments and return a row containing
            # the prebuilt fee hash and the keys necessary for joining in to the complete trucking frame

            def initialize(version:, frame:)
              @frame = frame
              @version = version
            end

            attr_reader :version, :frame

            delegate :truck_type, :carriage, :tenant_vehicle_id, :zone, :cargo_class, to: :version

            VERSION_KEYS = %w[truck_type carriage tenant_vehicle_id zone cargo_class].freeze
            NON_FEE_KEYS = %w[truck_type direction carriage cargo_class zone service carrier mot carrier_code tenant_vehicle_id organization_id].freeze

            def frame_row
              {
                "fees" => fee_hash,
                "zone" => zone,
                "tenant_vehicle_id" => tenant_vehicle_id,
                "truck_type" => truck_type,
                "carriage" => carriage,
                "cargo_class" => cargo_class
              }
            end

            def fee_hash
              fee_codes.each_with_object({}) do |fee_code, result|
                result.merge!(
                  FeeFromRows.new(frame: sub_frame_for_fee(fee_code: fee_code)).fee
                )
              end
            end

            def sub_frame_for_fee(fee_code:)
              fee_frame[fee_frame["fee_code"] == fee_code][fee_frame.keys - NON_FEE_KEYS]
            end

            def relevant_rows(keys:)
              frame[keys.map { |key| (frame[key] == send(key)) }.reduce(&:&)]
            end

            def fee_frame
              @fee_frame ||= relevant_rows(keys: VERSION_KEYS)
            end

            def fee_codes
              @fee_codes ||= fee_frame["fee_code"].to_a.uniq
            end
          end

          # FeeFromRows builds the individual fee, constucting any ranges and removing all but the necessary keys
          class FeeFromRows
            CONTEXT_KEYS = %w[fee mot fee_code truck_type direction currency rate_basis carriage].freeze

            def initialize(frame:)
              @frame = frame
            end

            attr_reader :frame

            def fee
              row["range"] = ranges if row["rate_basis"].include?("RANGE")
              result = row.except("range_min", "range_max", "sheet_name")
              result["key"] = result.delete("fee_code")
              { result["key"] => result }
            end

            def ranges
              frame.to_a.map do |range_row|
                range_row.except("fee", "fee_code", "currency", "sheet_name", "rate_basis").compact.transform_keys { |k| k.gsub("range_", "") }
              end
            end

            def row
              @row ||= frame.to_a.first.compact
            end
          end
        end
      end
    end
  end
end
