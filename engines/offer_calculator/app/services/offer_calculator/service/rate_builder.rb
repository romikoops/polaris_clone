# frozen_string_literal: true

module OfferCalculator
  module Service
    class RateBuilder < Base
      SECTIONS = %w[
        trucking_pre
        export
        cargo
        import
        trucking_on
      ].freeze

      def self.fees(quotation:, shipment:, inputs:)
        new(quotation: quotation, shipment: shipment).perform(inputs: inputs)
      end

      def initialize(quotation:, shipment:)
        @cargo = quotation.cargo
        super(shipment: shipment, quotation: quotation)
      end

      def perform(inputs:)
        results = inputs.flat_map { |section, rates|
          next if rates.blank?

          rates.map do |rate|
            measures = OfferCalculator::Service::Measurements::Cargo.new(
              cargo: cargo, object: rate, scope: scope
            )
            klass = "OfferCalculator::Service::RateBuilders::#{section.to_s.camelize}".constantize
            klass.fees(measures: measures, quotation: quotation)
          end
        }

        deduplicate_shipment_fees(results: results.compact.flatten)
      end

      private

      attr_reader :shipment, :quotation, :cargo

      def deduplicate_shipment_fees(results:)
        results.uniq do |result|
          [
            result.tenant_vehicle_id,
            result.target&.id,
            result.charge_category.code,
            result.validity,
            result.section,
            result.filter_id
          ]
        end
      end
    end
  end
end
