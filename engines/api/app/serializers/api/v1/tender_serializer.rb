# frozen_string_literal: true

module Api
  module V1
    class TenderSerializer < Api::ApplicationSerializer
      attributes %i[origin destination carrier service_level mode_of_transport total shipment_id charge_trip_id]
      delegate :origin_hub, :destination_hub, :service_level, :transit_time,
               :mode_of_transport, :shipment_id, :charge_trip_id, to: :meta
      delegate :meta, to: :object

      attribute :transit_time, unless: :quotation_tool?

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
    end
  end
end
