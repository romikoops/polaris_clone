# frozen_string_literal: true

module Wheelhouse
  class TenderDecorator < Draper::Decorator
    decorates 'Quotations::Tender'
    delegate_all

    def origin
      origin_hub.name
    end

    def destination
      destination_hub.name
    end

    def carrier
      tenant_vehicle.carrier&.name
    end

    def service_level
      tenant_vehicle.name
    end

    def transshipment
      object.transshipment || 'direct'
    end

    def estimated
      context.fetch(:estimated, false)
    end

    def transit_time
      trip = itinerary.trips.find_by(tenant_vehicle: tenant_vehicle, load_type: load_type)
      return '-' if trip.blank?

      (trip.end_date.to_date - trip.start_date.to_date).to_i
    end

    def total
      return nil if amount_cents.zero?

      {
        amount: amount_cents / 100.to_f,
        currency: amount_currency
      }
    end

    def uuid
      SecureRandom.uuid
    end
  end
end
