# frozen_string_literal: true

module OfferCalculator
  module Service
    class PricingManipulator < Base
      attr_reader :request

      def self.manipulated_pricings(request:, associations:, schedules:)
        new(request: request).perform(associations: associations, schedules: schedules)
      end

      def perform(associations:, schedules:)
        associations.each_with_object({}) do |(key, association), results|
          klass = "OfferCalculator::Service::Manipulators::#{key.to_s.camelize}".constantize
          results[key] = klass.results(association: association,
                                       request: request,
                                       schedules: schedules)
          check_for_fee_type(type: key, results: results[key])
        end
      end
    end
  end
end
