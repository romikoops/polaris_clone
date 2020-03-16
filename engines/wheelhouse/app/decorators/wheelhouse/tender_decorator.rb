# frozen_string_literal: true

module Wheelhouse
  class TenderDecorator < Draper::Decorator
    decorates 'Wheelhouse::OpenStruct'

    delegate :origin_hub, :destination_hub, :service_level, :transit_time,
             :mode_of_transport, :shipment_id, :charge_trip_id, to: :meta
    delegate :meta, to: :object

    def origin
      origin_hub.name
    end

    def destination
      destination_hub.name
    end

    def carrier
      object.dig('meta', 'carrier_name')
    end

    def total
      return '' if object.dig('quote', 'total', 'value').blank?

      Money.new(object.quote.total.value.to_d * 100, object.quote.total.currency).format
    end

    def uuid
      SecureRandom.uuid
    end
  end
end
