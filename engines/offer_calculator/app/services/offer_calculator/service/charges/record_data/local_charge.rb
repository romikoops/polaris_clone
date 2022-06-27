# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module RecordData
        class LocalCharge
          attr_reader :record

          def initialize(record:)
            @record = record
          end

          def perform
            OfferCalculator::Service::Charges::Support::ChargeCategoryData.new(
              frame: Rover::DataFrame.new(local_charge_fee_rows)
            ).perform
          end

          private

          delegate :hub_id, :direction, :mode_of_transport, :load_type, :id, :tenant_vehicle,
            :effective_date, :expiration_date, :fees, to: :record

          def local_charge_fee_rows
            @local_charge_fee_rows ||= OfferCalculator::Service::Charges::Support::FeeExpansion.new(
              fees: fees, base: local_charge_info
            ).perform
          end

          def local_charge_info
            record.slice("tenant_vehicle_id", "organization_id", "metadata", "mode_of_transport").merge(
              "origin_hub_id" => hub_id,
              "destination_hub_id" => hub_id,
              "section" => direction,
              "margin_type" => "#{direction}_margin",
              "direction" => direction,
              "cbm_ratio" => Pricings::Pricing::WM_RATIO_LOOKUP[mode_of_transport],
              "vm_ratio" => 1,
              "cargo_class" => load_type,
              "load_type" => load_type == "lcl" ? "cargo_item" : "container",
              "context_id" => id,
              "source_type" => record.class.name,
              "source_id" => id,
              "carrier_lock" => tenant_vehicle.carrier_lock,
              "carrier_id" => tenant_vehicle.carrier_id,
              "effective_date" => effective_date.to_date,
              "expiration_date" => expiration_date.to_date
            )
          end
        end
      end
    end
  end
end
