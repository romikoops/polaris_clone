# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class LocalCharge < ExcelDataServices::V3::Formatters::Base
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

        def insertable_data
          frame[GROUPING_KEYS].to_a.uniq.map { |grouping| FormattedLocalCharge.new(frame: frame.filter(grouping), state: state).perform }
        end

        class FormattedLocalCharge
          NAMESPACE_UUID = ::UUIDTools::UUID.parse(Legacy::LocalCharge::UUID_V5_NAMESPACE)
          UUID_KEYS = %w[hub_id counterpart_hub_id tenant_vehicle_id cargo_class mode_of_transport group_id direction organization_id].freeze
          def initialize(frame:, state:)
            @frame = frame
            @state = state
          end

          def perform
            local_charge_attrs.merge(data_from_frame)
          end

          private

          attr_reader :frame, :state

          def local_charge_attrs
            row.slice(
              "effective_date",
              "expiration_date",
              "hub_id",
              "counterpart_hub_id",
              "group_id",
              "tenant_vehicle_id",
              "mode_of_transport",
              "organization_id",
              "direction",
              "dangerous",
              "internal",
              "cbm_ratio"
            )
          end

          def row
            @row ||= frame.to_a.first
          end

          def data_from_frame
            {
              "metadata" => metadata,
              "fees" => FeesHash.new(frame: frame, state: state).perform,
              "load_type" => row["cargo_class"],
              "validity" => "[#{row['effective_date'].to_date}, #{row['expiration_date'].to_date})",
              "uuid" => uuid
            }
          end

          def metadata
            row.slice("sheet_name").tap do |combined_metadata|
              combined_metadata["row_number"] = frame["row"].to_a.join(",")
              combined_metadata["file_name"] = state.file_name
              combined_metadata["document_id"] = state.file.id
            end
          end

          def uuid
            ::UUIDTools::UUID.sha1_create(NAMESPACE_UUID, row.values_at(*UUID_KEYS).map(&:to_s).join).to_s
          end
        end

        class FeesHash
          attr_reader :frame, :state

          def initialize(frame:, state:)
            @frame = frame
            @state = state
          end

          def perform
            fee_codes.each_with_object({}) do |fee_code, fee_result|
              fee_result[fee_code.upcase] = FeeHash.new(frame: frame.filter("fee_code" => fee_code), state: state).perform
            end
          end

          def fee_codes
            frame["fee_code"].to_a.uniq
          end
        end

        class FeeHash
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

          def perform
            row.slice("organization_id", "base", "min", "max", "rate_basis", "currency", "rate")
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
