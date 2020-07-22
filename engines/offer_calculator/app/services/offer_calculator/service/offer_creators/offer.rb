# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Offer < OfferCalculator::Service::OfferCreators::Base
        attr_reader :shipment, :quotation, :result, :schedules

        delegate :load_type, to: :shipment

        def initialize(offer:, shipment:, quotation:, schedules:)
          @quotation = quotation
          @schedules = schedules
          @result = offer
          super(shipment: shipment)
        end

        def charges
          @charges ||= result.values.flatten
        end

        def valid_until
          @valid_until ||= begin
            return scope.dig(:validity_period).days.from_now.to_date if scope.dig(:validity_period)

            charges.map { |charge_section| charge_section.validity.last }.min
          end
        end

        def valid_from
          @valid_from ||= charges.map { |charge_section| charge_section.validity.first }.max
        end

        def total
          charges.sum(&:value).exchange_to(currency_for_user)
        end

        def sections
          result.values
        end

        def section(key:)
          result.dig(key)
        end

        def pricing_ids(section_key:)
          section(key: section_key).map(&:pricing_id)
        end

        def itinerary
          target = section(key: "cargo")
          return if target.blank?

          Legacy::Itinerary.find_by(id: target.first.itinerary_id)
        end

        def tenant_vehicle(section_key:)
          target = section(key: section_key)

          return if target.blank?

          Legacy::TenantVehicle.find_by(id: target.first.tenant_vehicle_id)
        end

        def truck_type(carriage:)
          target = section(key: "trucking_#{carriage}")

          return if target.blank?

          target.first.truck_type
        end
      end
    end
  end
end
