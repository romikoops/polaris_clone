# frozen_string_literal: true

module Integrations
  module ChainIo
    class Builder
      delegate :eta, :etd, :incoterm_text, :created_by, to: :@shipment_request
      delegate :containers, :containerization_type, :packages, to: :@cargo
      delegate :origin, :destination, to: :@tender

      def initialize(shipment_request_id: nil, options: {})
        @shipment_request = ShipmentRequest.find(shipment_request_id)
        @tender = @shipment_request.tender
        @cargo = @tender.quotation.cargo
        @data = {}
      end

      def prepare
        shipment = {
          'lading_port' => origin,
          'departure_estimated' => etd,
          'arrival_port' => destination,
          'arrival_port_estimated' => eta,
          'freight_payment_terms' => freight_payment_terms,
          'inco_term' => incoterm_text,
          'consignee' => consignee,
          'consignor' => consignor,
          'containerization_type' => containerization_type,
          'containers' => units[:containers],
          'created_by' => created_by,
          'transport_mode' => transport_mode,
          'package_group' => units[:packages]
        }
        @data = { shipments: [shipment] }
      end

      def consignee
        Integrations::ChainIo::Contact.new(@shipment_request.consignee.contact).format
      end

      def consignor
        Integrations::ChainIo::Contact.new(@shipment_request.consignor.contact).format
      end

      def transport_mode
        @tender.origin_hub.hub_type
      end

      def units
        @units ||= @cargo.prepare_units
      end

      def freight_payment_terms
        'Collect'
      end
    end
  end
end
