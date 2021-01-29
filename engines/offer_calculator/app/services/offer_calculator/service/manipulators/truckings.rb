# frozen_string_literal: true

module OfferCalculator
  module Service
    module Manipulators
      class Truckings < OfferCalculator::Service::Manipulators::Base
        private

        def arguments(object:)
          {
            dates: margin_dates(trucking: object),
            cargo_class_count: cargo_class_count,
            trucking_pricing: object
          }
        end

        def margin_type(object:)
          "trucking_#{object.carriage}_margin".to_sym
        end

        def margin_dates(trucking:)
          if trucking.carriage == "pre"
            pre_carriage_dates
          else
            on_carriage_dates
          end
        end
      end
    end
  end
end
