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
          @valid_until ||= if validity_period.present?
            validity_period.to_i.days.from_now.to_date
          else
            charges.map { |charge_section| charge_section.validity.last - 1.day } # ranges are exclusive of the end
              .select { |date| date > Time.zone.today.end_of_day }.min.end_of_day
          end
        end

        def valid_from
          @valid_from ||= charges.map { |charge_section| charge_section.validity.first }.max
        end

        def total
          @total ||= charges.inject(Money.new(0, currency_for_user)) do |sum, item|
            sum + item.value
          end.round
        end

        def sections
          OFFER_KEY_ORDER.map { |key| result[key] }.compact
        end

        def section_keys
          OFFER_KEY_ORDER.select { |key| result[key].present? }
        end

        def section(key:)
          result[key]
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

        def validity_period
          scope[:validity_period]
        end
      end
    end
  end
end
