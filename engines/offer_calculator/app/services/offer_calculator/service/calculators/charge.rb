# frozen_string_literal: true

module OfferCalculator
  module Service
    module Calculators
      class Charge
        attr_reader :value, :charge_category, :code, :name, :fee, :fee_component
        attr_accessor :line_item

        delegate :code, :name, to: :charge_category
        delegate :section, :load_type, :cargo_class, :validity, :itinerary_id, :tenant_vehicle_id,
          :pricing_id, :stackability, :targets, :charge_category, :truck_type, :hub_id, :object,
          :quantity, :chargeable_density, to: :fee

        def initialize(value:, fee:, fee_component:)
          @value = value
          @fee = fee
          @fee_component = fee_component
          @line_item = nil
        end

        delegate :min_value, to: :fee
        delegate :carrier_lock, :carrier_id, to: :tenant_vehicle

        def rounded_value
          value.round
        end

        def rate
          fee_component.value
        end

        def tenant_vehicle
          @tenant_vehicle ||= Legacy::TenantVehicle.find(tenant_vehicle_id)
        end

        def unit_value
          (value / quantity).round
        end
      end
    end
  end
end
