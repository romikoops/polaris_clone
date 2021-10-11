# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          augments.each do |key|
            value = state[key]
            frame[key] = value if value.present?
          end

          state
        end

        private

        def carriage_frame
          @carriage_frame ||= Rover::DataFrame.new(
            [{ "carriage" => "pre", "direction" => "export" }, { "carriage" => "on", "direction" => "import" }]
          )
        end

        def remove_sheet_name
          frame.delete("sheet_name")
          frame
        end

        def augments
          []
        end

        def find_or_create_service_level
          Legacy::TenantVehicle.find_or_create_by(
            name: service_string,
            carrier: carrier,
            organization_id: state.organization_id,
            mode_of_transport: mode_of_transport
          )
        end

        def carrier
          return nil if carrier_string.blank?

          code = carrier_string.downcase
          ActiveRecord::Base.transaction do
            Routing::Carrier.create_with(name: carrier_string).find_or_create_by!(code: code)
            Legacy::Carrier.create_with(name: carrier_string).find_or_create_by!(code: code)
          end
        end

        def service_string
          state.frame["service"].to_a.first
        end

        def mode_of_transport
          state.frame["mode_of_transport"].to_a.first
        end

        def carrier_string
          state.frame["carrier"].to_a.first
        end

        def correct_service_and_carrier_keys
          frame["carrier"] = frame.delete("courier") if frame.include?("courier")
          frame["carrier_code"] = frame["carrier"].map { |value| value&.downcase }
          frame["service"] = frame.delete("service_level") if frame.include?("service_level")
        end
      end
    end
  end
end
