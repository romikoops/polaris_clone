# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class DecoratedCharge
        FCL_CHARGEABLE_DENSITY = 0.0001
        SHIPMENT_LEVEL_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::SHIPMENT_LEVEL_RATE_BASES
        attr_reader :charge, :value
        attr_accessor :line_item

        CHARGE_DELEGATIONS = %i[fee measured_cargo].freeze
        delegate(*CHARGE_DELEGATIONS, to: :charge)

        MEASURED_CARGO_DELEGATIONS = %i[quantity object stackability].freeze
        delegate(*MEASURED_CARGO_DELEGATIONS, to: :measured_cargo)

        CONTEXT_DELEGATIONS = %i[
          source_id
          source_type
          effective_date
          expiration_date
          direction
          destination_hub_id
          origin_hub_id
          metadata
          section
          load_type
          cargo_class
          itinerary_id
          tenant_vehicle_id
          truck_type
          code
          carrier_lock
          carrier_id
          section
        ].freeze
        delegate(*CONTEXT_DELEGATIONS, to: :object)

        FEE_DELEGATIONS = %i[
          currency measure surcharge minimum_charge maximum_charge
          rate range_max range_min charge_category rate_basis percentage? base
        ].freeze
        delegate(*FEE_DELEGATIONS, to: :fee)

        delegate :name, to: :charge_category
        alias fee_component fee

        def initialize(charge:, value:)
          @charge = charge
          @value = value
          @line_item = nil
        end

        def rounded_value
          value.round
        end

        def unit_value
          (value / quantity).round
        end

        def validity
          Range.new(effective_date.to_date, expiration_date.to_date, exclude_end: true)
        end

        def hub_id
          direction == "export" ? destination_hub_id : origin_hub_id
        end

        def pricing_id
          { "Pricings::Pricing" => source_id }[source_type]
        end

        def tenant_vehicle
          @tenant_vehicle ||= Legacy::TenantVehicle.find(tenant_vehicle_id)
        end

        def chargeable_density
          return FCL_CHARGEABLE_DENSITY if /fcl/.match?(cargo_class)

          measured_cargo.chargeable_weight_in_tons.value / measured_cargo.volume.value
        end

        def targets
          SHIPMENT_LEVEL_RATE_BASES.include?(rate_basis) ? [] : measured_cargo.cargo_units
        end

        def breakdowns
          @breakdowns ||= OfferCalculator::Service::Charges::BreakdownBuilder.new(fee: fee, metadata: metadata).perform
        end

        alias min_value minimum_charge
      end
    end
  end
end
