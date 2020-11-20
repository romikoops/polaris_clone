# frozen_string_literal: true

module OfferCalculator
  module Service
    class ChargeCalculator < Base
      def self.charges(shipment:, quotation:, fees:)
        new(shipment: shipment, quotation: quotation, fees: fees).perform
      end

      def initialize(shipment:, quotation:, fees:)
        @fees = fees
        super(shipment: shipment, quotation: quotation)
      end

      def perform
        grouped_fees.flat_map do |grouped_fees|
          calculate_charges(grouped_fees: grouped_fees)
        end
      rescue
        raise OfferCalculator::Errors::CalculationError
      end

      private

      attr_reader :shipment, :fees

      def grouped_fees
        fees.group_by(&:object).values
      end

      def calculate_charges(grouped_fees:)
        standard_charges = build_standard_fees(input: grouped_fees)
        percentage_charges = build_percentage_fees(
          input: grouped_fees,
          standard_charges: standard_charges
        )

        standard_charges + percentage_charges
      end

      def build_standard_fees(input:)
        input.reject { |fee| fee.rate_basis == "PERCENTAGE" }
          .map do |fee|
          calulate_charge_from_fee(fee: fee)
        end
      end

      def build_percentage_fees(input:, standard_charges:)
        existing_total = standard_charges.sum(&:value)
        input.select { |fee| fee.rate_basis == "PERCENTAGE" }.map do |fee|
          component = fee.components.first
          percentage_value = percentage_result_from_component(
            percentage: component.percentage,
            total: existing_total,
            fee: fee
          )
          OfferCalculator::Service::Calculators::Charge.new(
            value: final_value_with_margin(fee: fee, value: percentage_value),
            fee: fee,
            fee_component: component
          )
        end
      end

      def percentage_result_from_component(percentage:, total:, fee:)
        (percentage * total).clamp(fee.min_value, fee.max_value)
      end

      def calulate_charge_from_fee(fee:)
        result = fee.components
          .map { |component| component_and_value(component: component, fee: fee) }
          .max_by { |calculation| calculation[:value] }

        OfferCalculator::Service::Calculators::Charge.new(
          value: final_value_with_margin(fee: fee, value: result[:value]),
          fee: fee,
          fee_component: result[:component]
        )
      end

      def final_value_with_margin(fee:, value:)
        value + fee.flat_margin
      end

      def component_and_value(component:, fee:)
        {
          component: component,
          value: value(component: component, fee: fee)
        }
      end

      def value(component:, fee:)
        handle_fee(component: component, fee: fee).clamp(fee.min_value, fee.max_value)
      end

      def handle_fee(component:, fee:)
        return handle_x_fees(component: component, fee: fee) if fee.rate_basis.match?(/_X_/)

        component.value * fee.measures.send(component.modifier).value
      end

      def handle_x_fees(component:, fee:)
        rate_basis = fee.rate_basis
        result = component.value * (fee.measures.send(component.modifier).value / component.base).ceil
        result *= component.base if rate_basis.match?(/.+_X_.+_FLAT/)
        result
      end
    end
  end
end
