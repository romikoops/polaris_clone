# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Charge
        SHIPMENT_LEVEL_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::SHIPMENT_LEVEL_RATE_BASES

        attr_reader :fee, :measured_cargo

        delegate :object, to: :measured_cargo
        delegate :context_id, :effective_date, :expiration_date, :metadata, :cargo_class, to: :object
        delegate :rate, :base, :rate_basis, :currency, :measure, :minimum_charge, :maximum_charge, :percentage?, :surcharge, to: :fee

        def initialize(fee:, measured_cargo:)
          @fee = fee
          @measured_cargo = measured_cargo
        end

        def value
          @value ||= if percentage?
            Money.new(0, currency)
          else
            (calculated_value + surcharge).clamp(minimum_charge, maximum_charge)
          end
        end

        def grouping_values
          [context_id, effective_date, expiration_date]
        end

        private

        def calculated_value
          @calculated_value ||= if base.zero?
            rate * calculation_measure
          else
            rate * (calculation_measure / base).ceil
          end
        end

        def calculation_measure
          SHIPMENT_LEVEL_RATE_BASES.exclude?(rate_basis) ? measure : 1
        end
      end
    end
  end
end
