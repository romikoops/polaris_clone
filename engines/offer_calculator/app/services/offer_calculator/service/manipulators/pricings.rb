# frozen_string_literal: true

module OfferCalculator
  module Service
    module Manipulators
      class Pricings < OfferCalculator::Service::Manipulators::Base
        private

        def margin_type(object: nil)
          :freight_margin
        end

        def arguments(object:)
          {
            dates: export_dates,
            cargo_class_count: shipment.cargo_classes.count,
            pricing: object
          }
        end
      end
    end
  end
end
