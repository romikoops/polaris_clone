# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Document, type: :model do
    it { is_expected.to have_attribute(:attachable_type) }
    it { is_expected.to have_attribute(:attachable_id) }
    it { is_expected.to respond_to(:attachable) }

    it 'is shipment attachable' do
      shipment_doc = FactoryBot.build(:shipments_document, :shipment_doc)
      expect(shipment_doc.attachable).to be_a(Shipments::Shipment)
    end

    it 'is shipment_request attachable' do
      request_doc = FactoryBot.build(:shipments_document, :request_doc)
      expect(request_doc.attachable).to be_a(Shipments::ShipmentRequest)
    end
  end
end
