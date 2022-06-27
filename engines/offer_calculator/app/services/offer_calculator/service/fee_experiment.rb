# frozen_string_literal: true

module OfferCalculator
  module Service
    class FeeExperiment
      include Scientist

      attr_reader :request, :schedules, :associations

      delegate :scope, to: :request

      def initialize(request:, schedules:, associations:)
        @request = request
        @schedules = schedules
        @associations = associations
      end

      def perform
        case scope["calculation_strategy"]
        when "experiment"
          experimental_charges
        when "new"
          new_charges
        else
          legacy_charges
        end
      end

      def experimental_charges
        science "quotation-calculation" do |experiment|
          experiment.run_if { !Rails.env.test? }

          experiment.context request: request

          experiment.use do
            legacy_charges
          end

          experiment.try do
            new_charges
          end

          # Prepare values to compare old to new
          experiment.clean do |values|
            sorted_values = values.sort_by(&:code)
            {
              results: sorted_values.map do |sorted_value|
                {
                  code: sorted_value.code,
                  value: sorted_value.value,
                  tenant_vehicle_id: sorted_value.tenant_vehicle_id
                }
              end
            }
          end

          experiment.compare do |control, candidate|
            sorted_control = control.sort_by(&:code)
            sorted_candidate = candidate.sort_by(&:code)
            sorted_control.map(&:code) == sorted_candidate.map(&:code) &&
              sorted_control.map(&:value) == sorted_candidate.map(&:value) &&
              sorted_control.map(&:tenant_vehicle_id) == sorted_candidate.map(&:tenant_vehicle_id)
          end
        end
      end

      private

      # New Charges Module Code
      def new_charges
        @new_charges ||= OfferCalculator::Service::FeeBuilder.fees(
          request: request, associations: associations, schedules: schedules
        )
      end

      # Legacy Code
      def fees
        @fees ||= OfferCalculator::Service::RateBuilder.fees(
          request: request, inputs: manipulated_rates
        )
      end

      def manipulated_rates
        @manipulated_rates ||= OfferCalculator::Service::PricingManipulator.manipulated_pricings(
          request: request, schedules: schedules, associations: associations
        )
      end

      def legacy_charges
        @legacy_charges ||= OfferCalculator::Service::ChargeCalculator.charges(
          request: request, fees: fees
        )
      end
    end
  end
end
