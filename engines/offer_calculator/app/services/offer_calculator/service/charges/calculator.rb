# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Calculator
        def initialize(charges:)
          @charges = charges
        end

        def perform
          grouped_charges.flat_map do |group_of_charges|
            CalculatorCharges.new(charges: group_of_charges).calculated_charges
          end
        rescue ArgumentError
          raise OfferCalculator::Errors::CalculationError
        end

        private

        attr_reader :charges

        def grouped_charges
          charges.group_by(&:grouping_values).values
        end

        class CalculatorCharges
          def initialize(charges:)
            @charges = charges
          end

          def calculated_charges
            non_percentage_calculator_charges + percentage_charges
          end

          private

          attr_reader :charges

          def non_percentage_calculator_charges
            @non_percentage_calculator_charges ||= non_percentage_charges.map do |charge|
              OfferCalculator::Service::Charges::DecoratedCharge.new(charge: charge, value: charge.value)
            end
          end

          def percentage_charges
            @percentage_charges ||= charges.select(&:percentage?).map do |charge|
              PercentageChargeCalculator.new(charge: charge, total: non_percentage_total).perform
            end
          end

          def non_percentage_charges
            @non_percentage_charges ||= charges.reject(&:percentage?)
          end

          def non_percentage_total
            @non_percentage_total ||= non_percentage_calculator_charges.sum(&:value)
          end
        end

        class PercentageChargeCalculator
          NON_MEASURE_RATE_BASES = %w[PER_SHIPMENT PERCENTAGE].freeze

          def initialize(charge:, total:)
            @charge = charge
            @total = total
          end

          delegate :surcharge, :minimum_charge, :maximum_charge, :percentage?, :rate, to: :charge

          def perform
            OfferCalculator::Service::Charges::DecoratedCharge.new(
              charge: charge,
              value: value
            )
          end

          private

          attr_reader :charge, :total

          def value
            @value ||= ((total * rate) + surcharge).clamp(minimum_charge, maximum_charge)
          end
        end
      end
    end
  end
end
