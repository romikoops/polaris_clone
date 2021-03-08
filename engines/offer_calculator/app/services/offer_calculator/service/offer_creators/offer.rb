# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Offer < OfferCalculator::Service::OfferCreators::Base
        OFFER_KEY_ORDER = %w[trucking_pre export cargo import trucking_on].freeze

        attr_reader :request, :result, :schedules

        delegate :load_type, to: :request

        def initialize(offer:, request:, schedules:)
          @request = request
          @schedules = schedules
          @result = offer
          super(request: request)
        end

        def charges
          @charges ||= result.values.flatten
        end

        def valid_until
          @valid_until ||= begin
            return scope.fetch(:validity_period).days.from_now.to_date if scope.dig(:validity_period).present?

            charges.map { |charge_section| charge_section.validity.last }
              .select { |date| date > Time.zone.today.end_of_day }.min
          end
        end

        def valid_from
          @valid_from ||= charges.map { |charge_section| charge_section.validity.first }.max
        end

        def total
          @total ||= charges.inject(Money.new(0, currency_for_user)) { |sum, item|
            sum + item.value
          }.round
        end

        def sections
          OFFER_KEY_ORDER.map { |key| result[key] }.compact
        end

        def section_keys
          OFFER_KEY_ORDER.select { |key| result[key].present? }
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
