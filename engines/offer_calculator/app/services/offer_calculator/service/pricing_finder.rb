# frozen_string_literal: true

module OfferCalculator
  module Service
    class PricingFinder < OfferCalculator::Service::Base
      def self.pricings(shipment:, quotation:, schedules:)
        new(shipment: shipment, quotation: quotation).perform(schedules: schedules)
      end

      def perform(schedules:)
        %i[truckings local_charges pricings].each_with_object({}) do |key, results|
          klass = "OfferCalculator::Service::Finders::#{key.to_s.camelize}".constantize
          results[key] = klass.prices(shipment: shipment, quotation: quotation, schedules: schedules)
          check_for_fee_type(type: key, results: results[key])
        end
      end
    end
  end
end
