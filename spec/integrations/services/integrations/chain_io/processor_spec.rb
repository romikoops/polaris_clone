# frozen_string_literal: true

require "rails_helper"

module Integrations
  module ChainIo
    RSpec.describe Processor do
      let(:shipment_request_id) { "123" }
      let(:data) { {shipment: {data: "data"}} }
      let(:organization) { FactoryBot.create(:organizations_organization) }

      it "builds and sends data to chain.io" do
        builder = double("Builder")
        sender = double("Sender")

        allow(Builder).to receive(:new).with(shipment_request_id: shipment_request_id).and_return(builder)
        allow(Sender).to receive(:new).with(data: data, organization_id: organization.id).and_return(sender)
        allow(builder).to receive(:prepare).and_return(data)
        allow(sender).to receive(:send_shipment)

        Processor.process(shipment_request_id: shipment_request_id, organization_id: organization.id)

        expect(Builder).to have_received(:new).with(shipment_request_id: shipment_request_id)
        expect(Sender).to have_received(:new).with(data: data, organization_id: organization.id)
        expect(sender).to have_received(:send_shipment).exactly(1).times
      end
    end
  end
end
