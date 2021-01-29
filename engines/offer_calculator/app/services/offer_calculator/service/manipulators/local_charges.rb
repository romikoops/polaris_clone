# frozen_string_literal: true

module OfferCalculator
  module Service
    module Manipulators
      class LocalCharges < OfferCalculator::Service::Manipulators::Base
        private

        def margin_type(object:)
          case object.direction
          when "export"
            :export_margin
          when "import"
            :import_margin
          else
            raise OfferCalculator::Errors::InvalidDirection
          end
        end

        def margin_dates(local_charge:)
          if local_charge.direction == "export"
            export_dates
          else
            import_dates
          end
        end

        def arguments(object:)
          {
            cargo_class: object.load_type,
            cargo_class_count: cargo_class_count,
            dates: margin_dates(local_charge: object),
            local_charge: object
          }
        end
      end
    end
  end
end
