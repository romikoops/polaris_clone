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

      def self.fees(request:, inputs:)
        new(request: request).perform(inputs: inputs)
      end

      def perform(inputs:)
        results = inputs.flat_map { |section, rates|
          next if rates.blank?

          rates.map do |rate|
            measures = OfferCalculator::Service::Measurements::Request.new(
              request: request, object: rate, scope: scope
            )
            klass = "OfferCalculator::Service::RateBuilders::#{section.to_s.camelize}".constantize
            klass.fees(measures: measures, request: request)
          end
        }

        deduplicate_shipment_fees(results: results.compact.flatten)
      end

      private

      attr_reader :request

      def deduplicate_shipment_fees(results:)
        results.uniq do |result|
          [
            result.tenant_vehicle_id,
            result.targets.pluck(:id).join,
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
