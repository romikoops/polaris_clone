# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class LocalCharge < ExcelDataServices::V4::Formatters::Base
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
          frame.group_by(GROUPING_KEYS).map { |grouping| FormattedLocalCharge.new(frame: grouping, state: state).perform }
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
              "internal"
            )
          end

          def row
            @row ||= frame.to_a.first
          end

          def data_from_frame
            {
              "metadata" => metadata,
              "fees" => JsonFeeStructure.new(frame: frame).perform,
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
      end
    end
  end
end
