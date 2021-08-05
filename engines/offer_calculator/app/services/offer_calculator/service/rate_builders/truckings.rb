# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Truckings < OfferCalculator::Service::RateBuilders::Base
        attr_reader :value, :charge_category, :code, :name

        def perform
          @fees = measures.targets.map do |target_measure|
            Ranges::Fee.new(measure: target_measure, modifier: object.result["modifier"], request: request).fee
          end
          super
        end
      end
    end
  end
end
