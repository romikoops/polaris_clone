# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe ShipmentRequest, type: :model do
    it 'has many documents as attachables' do
      is_expected.to respond_to(:documents)
    end

    it 'creates a valid shipment request' do
      shipment_request = FactoryBot.create :shipments_shipment_request
      expect(shipment_request.valid?).to eql(true)
    end

    it 'creates a an object with consignee, consignor, and notifyee' do
      shipment_request = FactoryBot.build :shipments_shipment_request

      consignee = FactoryBot.build(:shipments_shipment_request_contact, :as_consignee)
      consignor = FactoryBot.build(:shipments_shipment_request_contact, :as_consignor)
      notifyees = FactoryBot.build_list(:shipments_shipment_request_contact, 2, :as_notifyee)

      shipment_request.consignee = consignee
      shipment_request.consignor = consignor
      shipment_request.notifyees = notifyees

      expect(shipment_request.consignee.type).to eq('Shipments::ShipmentRequestContacts::Consignee')
      expect(shipment_request.consignor.type).to eq('Shipments::ShipmentRequestContacts::Consignor')
      expect(shipment_request.notifyees.first.type).to eq('Shipments::ShipmentRequestContacts::Notifyee')
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_requests
#
#  id                :uuid             not null, primary key
#  status            :integer
#  quote_id          :integer
#  total_goods_value :money
#  cargo_notes       :string
#  notes             :string
#  incoterm_text     :string
#  eori              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
