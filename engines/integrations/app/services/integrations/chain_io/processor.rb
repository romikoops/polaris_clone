# frozen_string_literal: true

module Integrations
  module ChainIo
    class Processor
      def self.process(shipment_request_id:, organization_id:)
        builder = Builder.new(shipment_request_id: shipment_request_id)
        data = builder.prepare

        Sender.new(data: data, organization_id: organization_id).send_shipment
      end
    end
  end
end
