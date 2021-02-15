# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            return state if frame.empty?

            state.frame = correct_frame
            create_service_level
            state
          end

          def correct_frame
            frame["carrier"] = frame.delete("courier") if frame.include?("courier")
            frame["service"] = frame.delete("service_level") if frame.include?("service_level")
            frame.delete("city")
            frame.inner_join(carriage_frame, on: {"direction" => "direction"})
          end

          def create_service_level
            Legacy::TenantVehicle.find_or_create_by(
              name: service_string,
              carrier: carrier,
              organization_id: state.organization_id,
              mode_of_transport: mode_of_transport)
          end

          def carrier
            return nil if carrier_string.blank?

            Legacy::Carrier.find_or_initialize_by(code: carrier_string.downcase).tap do |new_carrier|
              new_carrier.name = carrier_string if new_carrier.name.blank?
              new_carrier.save
            end
          end

          def augments
            %w[hub_id group_id organization_id]
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
        end
      end
    end
  end
end
