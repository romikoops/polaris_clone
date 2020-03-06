# frozen_string_literal: true

module Api
  module V1
    class TenderSerializer < ActiveModel::Serializer
      attributes %i[origin destination carrier service_level mode_of_transport total shipment_id charge_trip_id]
      delegate :origin_hub, :destination_hub, :carrier, :service_level, :transit_time,
               :mode_of_transport, :shipment_id, :charge_trip_id, to: :meta
      delegate :meta, to: :object

      attribute :transit_time, unless: :quotation_tool?

      def origin
        origin_hub.name
      end

      def destination
        destination_hub.name
      end

      def total
        {
          value: object.quote.total.value.to_f,
          currency: object.quote.total.currency
        }
      end

      def quotation_tool?
        scope['open_quotation_tool'] || scope['closed_quotation_tool']
      end
    end
  end
end
